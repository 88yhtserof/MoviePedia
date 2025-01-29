//
//  CinemaViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import UIKit
import SnapKit

final class CinemaViewController: BaseViewController {
    
    private lazy var profileInfoView = ProfileInfoView(user: user)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let recentSearchesRemoveAllButton = UIButton()
    private let searchBarButtonItem = UIBarButtonItem()
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private var user = UserDefaultsManager.user!
    private var recentSearches: [String] = UserDefaultsManager.recentSearches
    private var todayMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
        configureCollectionViewDataSource()
        loadTodayMovies()
    }
    
    @objc func presentProfileEditVC() {
        let profileNicknameEditVC = ProfileNicknameEditViewController()
        present(profileNicknameEditVC, animated: true)
    }
    
    @objc func removeAllRecentSearches() {
        UserDefaultsManager.recentSearches = []
        recentSearches = []
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        let movie = todayMovies[sender.tag]
        if sender.isSelected {
            user.likedMovies.insert(movie)
        } else {
            user.likedMovies.remove(movie)
        }
        UserDefaultsManager.user = user
    }
    
    private func loadTodayMovies() {
        let trendingRequest = TrendingRequest()
        TMDBNetworkManager.shared.request(api: .treding(trendingRequest)) { (trending: TrendingResponse) in
            self.todayMovies = trending.results
            self.updateSnapshot(for: .todayMovie)
        } failureHandler: { error in
            print("Need to handle error")
        }

    }
}

//MARK: - Configuration
private extension CinemaViewController {
    func configureViews() {
        searchBarButtonItem.tintColor = .moviepedia_point
        searchBarButtonItem.image = UIImage(systemName: "magnifyingglass")
        navigationItem.rightBarButtonItem = searchBarButtonItem
        navigationItem.title = "MOVIE PEDIA"
        
        profileInfoView.userInfoButton.addTarget(self, action: #selector(presentProfileEditVC), for: .touchUpInside)
        
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        recentSearchesRemoveAllButton.setTitle("전체 삭제", for: .normal)
        recentSearchesRemoveAllButton.setTitleColor(.moviepedia_point, for: .normal)
        recentSearchesRemoveAllButton.addTarget(self, action: #selector(removeAllRecentSearches), for: .touchUpInside)
    }
    
    func configureHierarchy() {
        view.addSubviews(profileInfoView, collectionView)
    }
    
    func configureConstraints() {
        profileInfoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileInfoView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
    }
    
    func configureCollectionViewDataSource() {
        let emptyRecentSearchCellRegistration = UICollectionView.CellRegistration(handler: emptyResentSearchCellRegisterHandler)
        let recentSearchCellRegistration = UICollectionView.CellRegistration(handler: recentSearchCellRegidtrationHandler)
        let todayMovieCellRegidtration = UICollectionView.CellRegistration(handler: todayMovieCellRegidtrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown Section")
            }
            var cell: UICollectionViewCell
            
            switch section {
            case .emptyRecentSearch:
                cell = collectionView.dequeueConfiguredReusableCell(using: emptyRecentSearchCellRegistration, for: indexPath, item: itemIdentifier.empty)
            case .recentSeach:
                cell = collectionView.dequeueConfiguredReusableCell(using: recentSearchCellRegistration, for: indexPath, item: itemIdentifier.recentSearch)
            case .todayMovie:
                cell  = collectionView.dequeueConfiguredReusableCell(using: todayMovieCellRegidtration, for: indexPath, item: itemIdentifier.todayMovie)
            }
            
            return cell
        })
        
        let headerSupplementaryProvider = UICollectionView.SupplementaryRegistration(elementKind: "title-element-kind", handler: headerSupplementaryRegistrationHandler)
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementaryProvider, for: indexPath)
        }
        
        createSnapshot()
        collectionView.dataSource = dataSource
    }
}

//MARK: - CollectionView Layout
private extension CinemaViewController {
    func layout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProviderHandler, configuration: config)
    }
    
    func sectionProviderHandler(sectionIndex: Int, layoutEnviroment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        guard let section = Section(rawValue: sectionIndex) else {
            fatalError("Unknown Section")
        }
        
        switch section {
        case .emptyRecentSearch:
            return sectionForEmptyRecentSearch()
        case .recentSeach:
            return sectionForRecentSearch()
        case .todayMovie:
            return sectionForTodayMovie()
        }
    }
    
    func sectionForEmptyRecentSearch() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [ titleBoundarySupplementaryItem() ]
        return section
    }
    
    func sectionForRecentSearch() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .estimated(100.0), heightDimension: .absolute(30))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func sectionForTodayMovie() -> NSCollectionLayoutSection  {
        let (offset, sectionInset, recentSearch, header) = (8.0, 10.0, 30.0, 50.0)
        let height = collectionView.frame.height - (offset * 2 + sectionInset + recentSearch + header * 2)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [titleBoundarySupplementaryItem()]
        return section
    }
    
    func titleBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: "title-element-kind", alignment: .top)
    }
}

//MARK: - DataSource
extension CinemaViewController {
    enum Section: Int, CaseIterable {
        case emptyRecentSearch
        case recentSeach
        case todayMovie
    }
    
    struct Item: Hashable {
        let empty: String?
        let recentSearch: String?
        let todayMovie: Movie?
        
        private init(empty: String?, recentSearch: String?, todayMovie: Movie?) {
            self.empty = empty
            self.recentSearch = recentSearch
            self.todayMovie = todayMovie
        }
        
        init(empty: String) {
            self.init(empty: empty, recentSearch: nil, todayMovie: nil)
        }
        
        init(recentSearch: String) {
            self.init(empty: nil, recentSearch: recentSearch, todayMovie: nil)
        }
        
        init(todayMovie: Movie) {
            self.init(empty: nil, recentSearch: nil, todayMovie: todayMovie)
        }
        
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func emptyResentSearchCellRegisterHandler(cell: EmptyCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func recentSearchCellRegidtrationHandler(cell: RecentSearchCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func todayMovieCellRegidtrationHandler(cell: TodayMovieCollectionViewCell, indexPath: IndexPath, item: Movie) {
        let isLiked = user.likedMovies.isSuperset(of: [item])
        let todayMovie = TodayMovie(movie: item, isLiked: isLiked, index: indexPath.item)
        cell.configure(with: todayMovie)
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    func headerSupplementaryRegistrationHandler(supplementaryView: TitleSupplementaryView, string: String, indexPath: IndexPath) {
        if indexPath.section == 2 {
            supplementaryView.configure(with: "오늘의 영화")
            
        } else {
            supplementaryView.addRightAccessoryView(recentSearchesRemoveAllButton)
            supplementaryView.configure(with: "최근 검색어")
        }
    }
    
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        if recentSearches.isEmpty {
            let items = [Item(empty: "최근 검색 내역이 없습니다.")]
            snapshot.appendItems(items, toSection: .emptyRecentSearch)
        } else {
            let items = recentSearches.map{ Item(recentSearch: $0) }
            snapshot.appendItems(items, toSection: .recentSeach)
        }
        let items = todayMovies.map{ Item(todayMovie: $0) }
        snapshot.appendItems(items, toSection: .todayMovie)
        
        dataSource.apply(snapshot)
    }
    
    func updateSnapshot(for section: Section) {
        var items: [Item]
        switch section {
        case .emptyRecentSearch:
            items = [Item(empty: "최근 검색 내역이 없습니다.")]
        case .recentSeach:
            items = recentSearches.map{ Item(recentSearch: $0) }
        case .todayMovie:
            items = todayMovies.map{ Item(todayMovie: $0) }
        }
        snapshot.appendItems(items, toSection: section)
        snapshot.reloadSections([section])
        dataSource.apply(snapshot)
        
    }
}
