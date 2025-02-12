//
//  CinemaViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import UIKit
import SnapKit

final class CinemaViewController: BaseViewController {
    
    private lazy var profileInfoView = ProfileInfoView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let searchBarButtonItem = UIBarButtonItem()
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private var isUpdatingTodayMovieNeeded: Bool = false
    
    let viewModel = CinemaViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
        configureCollectionViewDataSource()
        bind()
    }
    
    func bind() {
        
        viewModel.output.updateTodayMovieSnapshot.lazyBind { [weak self] movies in
            print("Output updateTodayMovieSnapshot bind")
            guard let self, let movies else { return }
            self.updateTodayMovieSectionSnapshot(items: movies)
        }
        
        viewModel.output.updateRecentSearchSnapshot.lazyBind { [weak self] recentSearches in
            print("Output updateRecentSearchSnapshot bind")
            guard let self, let recentSearches else { return }
            self.updateRecentSearchSectionSnapshot(items: recentSearches)
        }
        
        viewModel.output.updateUser.lazyBind { [weak self] user in
            print("Out updateUser bind")
            guard let self, let user else { return }
            profileInfoView.user = user
        }
        
        viewModel.output.updateLikedMoviesCount.lazyBind { [weak self] likedMoviesCount in
            print("Out updateLikeMoviesCount bind")
            guard let self, let likedMoviesCount else { return }
            self.profileInfoView.updateLikedMoviesCount(likedMoviesCount)
        }
        
        viewModel.output.updateCellWithLikedMovie.lazyBind { [weak self] likedMovieInfo in
            guard let self, let (indexPath, isLiked) = likedMovieInfo else { return }
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? TodayMovieCollectionViewCell else {
                print("Could not find cell")
                return
            }
            cell.likeButton.isSelected = isLiked
        }
        viewModel.input.viewDidLoad.send()
    }
    
//    @objc func presentProfileEditVC() {
//        let profileNicknameEditVC = ProfileNicknameEditViewController(user: user, isEditedMode: true)
//        let profileNicknameEditNC = UINavigationController(rootViewController: profileNicknameEditVC)
//        if let sheet = profileNicknameEditNC.sheetPresentationController {
//            sheet.detents = [.large()]
//            sheet.prefersGrabberVisible = true
//        }
//        profileNicknameEditVC.saveProfileHandler = { user in
//            self.profileInfoView.user = user
//        }
//        present(profileNicknameEditNC, animated: true)
//    }
    
    @objc func removeAllRecentSearches() {
        UserDefaultsManager.recentSearches = []
        createSnapshot()
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        let likedResult = (sender.tag, sender.isSelected)
        viewModel.input.didLikedButtonTapped.send(likedResult)
    }
    
    @objc func searchBarButtonItemDidTapped() {
        pushToMovieSearchVC()
    }
    
    @objc func recentSearchesButtonTapped(_ sender: UIButton) {
        pushToMovieSearchVC(sender.attributedTitle(for: .normal)?.string)
    }
    
    func pushToMovieSearchVC(_ searchWord: String? = nil) {
        let movieSearchVC = MovieSearchViewController()
        movieSearchVC.viewModel.input.receiveSearchWord.send(searchWord)
        
        movieSearchVC.viewModel.output.updateLikedMovies.lazyBind { [weak self] likedMovieInfo in
            print("Output updateLikedMovies bind")
            guard let self else { return }
            self.viewModel.input.didChangeLikeMovies.send(likedMovieInfo)
        }
        
        movieSearchVC.viewModel.output.updateRecentSearches.lazyBind { [weak self] searchWord in
            print("Output updateRecentSearches bind")
            guard let self else { return }
            self.viewModel.input.didChangeRecentSearches.send(searchWord)
        }
        
        navigationController?.pushViewController(movieSearchVC, animated: true)
    }
}

//MARK: - Configuration
private extension CinemaViewController {
    func configureViews() {
        searchBarButtonItem.tintColor = .moviepedia_point
        searchBarButtonItem.image = UIImage(systemName: "magnifyingglass")
        searchBarButtonItem.target = self
        searchBarButtonItem.action = #selector(searchBarButtonItemDidTapped)
        navigationItem.rightBarButtonItem = searchBarButtonItem
        navigationItem.title = "MOVIE PEDIA"
        
//        profileInfoView.profileControlView.addTarget(self, action: #selector(presentProfileEditVC), for: .touchUpInside)
        
        collectionView.backgroundColor = .moviepedia_background
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
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
            var cell: UICollectionViewCell
            
            switch itemIdentifier {
            case .emptyRecentSearch(let items):
                cell = collectionView.dequeueConfiguredReusableCell(using: emptyRecentSearchCellRegistration, for: indexPath, item: items)
            case .recentSearch(let items):
                cell = collectionView.dequeueConfiguredReusableCell(using: recentSearchCellRegistration, for: indexPath, item: items.value)
            case .todayMovie(let items):
                cell  = collectionView.dequeueConfiguredReusableCell(using: todayMovieCellRegidtration, for: indexPath, item: items)
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
        case .recentSearch:
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
        let height = collectionView.frame.height - (offset * 2 + sectionInset * 2 + recentSearch + header * 2)
        let width: CGFloat = (3.0 * height) / 5.0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height))
        
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


//MARK: - CollectionView DataSource
extension CinemaViewController {
    enum Section: Int, CaseIterable {
        case emptyRecentSearch
        case recentSearch
        case todayMovie
    }
    
    enum Item: Hashable {
        case emptyRecentSearch(String)
        case recentSearch(Identifier<RecentSearch>)
        case todayMovie(MovieInfo)
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func emptyResentSearchCellRegisterHandler(cell: EmptyCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func recentSearchCellRegidtrationHandler(cell: RecentSearchCollectionViewCell, indexPath: IndexPath, item: RecentSearch) {
        cell.configure(with: item.search)
        cell.titleButton.addTarget(self, action: #selector(recentSearchesButtonTapped), for: .touchUpInside)
        cell.deleteAction = { [self] in
            viewModel.input.removeRecentSearch.send(item)
        }
    }
    
    func todayMovieCellRegidtrationHandler(cell: TodayMovieCollectionViewCell, indexPath: IndexPath, item: MovieInfo) {
        guard let movieInfo = viewModel.movieInfoList?[indexPath.item] else {
            print("Could not get movieInfo")
            return
        }
        cell.configure(with: movieInfo)
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    func headerSupplementaryRegistrationHandler(supplementaryView: TitleSupplementaryView, string: String, indexPath: IndexPath) {
        if indexPath.section == 2 {
            supplementaryView.configure(with: "오늘의 영화")
            
        } else {
            let removeAllButton = UIButton()
            removeAllButton.configuration = UIButton.Configuration.headerAccessoryButton("전체 삭제")
            removeAllButton.addTarget(self, action: #selector(removeAllRecentSearches), for: .touchUpInside)
            supplementaryView.addRightAccessoryView(removeAllButton)
            supplementaryView.configure(with: "최근 검색어")
        }
    }
    
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
    }
    
    func updateRecentSearchSectionSnapshot(items recentSearches: [RecentSearch]) {
        let exisitingEmptyRecentSearchItems = snapshot.itemIdentifiers(inSection: .emptyRecentSearch)
        let existingRecentSearchItems = snapshot.itemIdentifiers(inSection: .recentSearch)
        snapshot.deleteItems(exisitingEmptyRecentSearchItems + existingRecentSearchItems)
        
        if recentSearches.isEmpty {
            let items = [Item.emptyRecentSearch("최근 검색 내역이 없습니다.")]
            snapshot.appendItems(items, toSection: .emptyRecentSearch)
        } else {
            let items = recentSearches.sorted(by: {$0.date > $1.date}).map{ Item.recentSearch(Identifier(value: $0)) }
            snapshot.appendItems(items, toSection: .recentSearch)
        }
        
        dataSource.apply(snapshot)
    }
    
    func updateTodayMovieSectionSnapshot(items movieInfoList: [MovieInfo]) {
        let items = movieInfoList.map{ Item.todayMovie($0) }
        snapshot.appendItems(items, toSection: .todayMovie)
        dataSource.apply(snapshot)
    }
}

//MARK: - CollectionView Delegate
extension CinemaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2 {
//            let movieDetailVC = MovieDetailViewController(movie: todayMovies[indexPath.item])
//            movieDetailVC.likeButtonSelected = { (isLiked) in
//                guard let cell = collectionView.cellForItem(at: indexPath) as? TodayMovieCollectionViewCell else {
//                    print("Could not find cell")
//                    return
//                }
//                cell.likeButton.isSelected = isLiked
//            }
//            navigationController?.pushViewController(movieDetailVC, animated: true)
        }
    }
}
