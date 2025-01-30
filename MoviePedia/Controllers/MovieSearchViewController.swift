//
//  MovieSearchViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/29/25.
//

import UIKit
import SnapKit

final class MovieSearchViewController: BaseViewController {
    
    private let searchBar = DarkSearchBar()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let networkManager = TMDBNetworkManager.shared
    private var movies: [Movie] = []
    private var likedMovies: Set<Movie> = UserDefaultsManager.user?.likedMovies ?? []
    private var page: Int = 1
    
    init(searchWord: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let searchWord {
            searchBar.text = searchWord
            loadSearchResults(query: searchWord)
        } else {
            searchBar.becomeFirstResponder()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
        configureCollectionViewDataSource()
    }
    
    private func loadSearchResults(query: String, isInitial: Bool = true) {
        if isInitial { movies = [] }
        
        let request = SearchRequest(query: query, page: page)
        networkManager.request(api: .search(request)) { (value: MovieResponse) in
            self.movies.append(contentsOf: value.results)
            self.createSnapshot()
        } failureHandler: { error in
            print(error)
        }

    }
    
    private func updateRecentResults(_ recentSearch: RecentSearch) {
        var recentSearches = UserDefaultsManager.recentSearches
        if let index = recentSearches.firstIndex(where: { $0.search == recentSearch.search }) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(recentSearch)
        UserDefaultsManager.recentSearches = recentSearches
        postRecentSearchNotification()
    }
    
    private func postRecentSearchNotification() {
        NotificationCenter.default.post(name: NSNotification.Name("RecentSearch"), object: nil)
    }
    
    @objc func likedButtonTapped(_ sender: UIButton) {
        let movie = movies[sender.tag]
        if sender.isSelected {
            UserDefaultsManager.user!.likedMovies.insert(movie)
        } else {
            UserDefaultsManager.user!.likedMovies.remove(movie)
        }
        NotificationCenter.default.post(name: NSNotification.Name("LikedMovie"), object: nil)
    }
}

//MARK: - Configuration
private extension MovieSearchViewController {
    func configureViews() {
        searchBar.delegate = self
        
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .moviepedia_background
    }
    
    func configureHierarchy() {
        view.addSubviews(searchBar, collectionView)
    }
    
    func configureConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configureCollectionViewDataSource() {
        let emptyCellRegisteration = UICollectionView.CellRegistration(handler: emptyCellRegistrationHandler)
        let searchResultsCellRegisteration = UICollectionView.CellRegistration(handler: searchResultCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown Section")
            }
            
            switch section {
            case .empty:
                return collectionView.dequeueConfiguredReusableCell(using: emptyCellRegisteration, for: indexPath, item: itemIdentifier.empty)
            case .searchResults:
                return collectionView.dequeueConfiguredReusableCell(using: searchResultsCellRegisteration, for: indexPath, item: itemIdentifier.movie)
            }
        })
        
        createSnapshot()
        collectionView.dataSource = dataSource
    }
}

//MARK: - CollectionView DataSource
private extension MovieSearchViewController {
    enum Section: Int, CaseIterable {
        case empty
        case searchResults
    }
    
    struct Item: Hashable {
        let empty: String?
        let movie: Movie?
        
        private init(empty: String?, movie: Movie?) {
            self.empty = empty
            self.movie = movie
        }
        
        init(empty: String) {
            self.init(empty: empty, movie: nil)
        }
        
        init(movie: Movie) {
            self.init(empty: nil, movie: movie)
        }
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func emptyCellRegistrationHandler(cell: EmptyCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func searchResultCellRegistrationHandler(cell: MovieListCollectionViewCell, indexPath: IndexPath, item: Movie) {
        let isLiked = likedMovies.isSuperset(of: [item])
        let todayMovie = TodayMovie(movie: item, isLiked: isLiked, index: indexPath.item)
        cell.configure(with: todayMovie)
        cell.likeButton.addTarget(self, action: #selector(likedButtonTapped), for: .touchUpInside)
    }
    
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        if movies.isEmpty {
            let items = [Item(empty: "원하는 검색결과를 찾지 못했습니다")]
            snapshot.appendItems(items, toSection: .empty)
        } else {
            let items = movies.map{ Item(movie: $0) }
            snapshot.appendItems(items, toSection: .searchResults)
        }
        dataSource.apply(snapshot)
    }
    
    // TODO: - pagination 적용 시 데이터를 append하는 방식으로 개선
    func updateSnapshot() {
        
    }
}

//MARK: - CollectionView Layout
private extension MovieSearchViewController {
    func layout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProviderHandler)
    }
    
    func sectionProviderHandler(sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        guard let section = Section(rawValue: sectionIndex) else {
            fatalError("Unknown section")
        }
        
        switch section {
        case .empty:
            return sectionForEmpty()
        case .searchResults:
            return sectionForSearchResults()
        }
    }
    
    func sectionForEmpty() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.95))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    func sectionForSearchResults() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0/5.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}

//MARK: - SearchBar Delegate
extension MovieSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        guard let query = searchBar.text else { return }
        loadSearchResults(query: query)
        let recentSearch = RecentSearch(search: query, date: Date())
        updateRecentResults(recentSearch)
    }
}
