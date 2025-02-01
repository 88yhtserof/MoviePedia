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
    private var likedMovies: Set<Movie> { UserDefaultsManager.user?.likedMovies ?? [] }
    private var currentPage: Int = 1
    private var totalPage: Int?
    private var currentSearchWord: String?
    
    private var isUpdatingTodayMovieNeeded: Bool = false
    
    init(searchWord: String? = nil) {
        recenteSearchedWord = searchWord
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
        configureNotificationObserver()
        configureCollectionViewDataSource()
        
        if let recenteSearchedWord {
            searchBar.text = recenteSearchedWord
            loadSearchResults(query: recenteSearchedWord)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if recenteSearchedWord == nil && (searchBar.text?.isEmpty ?? true) {
            DispatchQueue.main.async() {
                self.searchBar.becomeFirstResponder()
            }
        }
    }
    
    private func loadSearchResults(query: String, isInitial: Bool = true) {
        if isInitial {
            currentPage = 1
            movies = []
        }
        
        let request = SearchRequest(query: query, page: currentPage)
        networkManager.request(api: .search(request)) { (value: MovieResponse) in
            self.currentPage += 1
            self.totalPage = value.total_pages
            self.movies.append(contentsOf: value.results)
            if isInitial {
                self.createSnapshot()
            } else {
                self.updateSnapshot(newItems:value.results, after: self.movies.count)
            }
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
        guard let movie = movies.first(where: { $0.id == sender.tag }) else { return }
        
        if sender.isSelected {
            UserDefaultsManager.user!.likedMovies.insert(movie)
        } else if let removeIndex = UserDefaultsManager.user!.likedMovies.firstIndex(where: {$0.id == movie.id }) {
            UserDefaultsManager.user!.likedMovies.remove(at: removeIndex)
        }
        NotificationCenter.default.post(name: NSNotification.Name("LikedMovie"), object: nil)
    }
    
    @objc func updateLikedMovie(_ notification: Notification) {
        isUpdatingTodayMovieNeeded = true
    }
}

//MARK: - Configuration
private extension MovieSearchViewController {
    func configureViews() {
        navigationItem.title = "영화 검색"
        
        searchBar.delegate = self
        
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .moviepedia_background
        collectionView.delegate = self
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
    
    func configureNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLikedMovie), name: NSNotification.Name("LikedMovie"), object: nil)
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
        let movie: MovieInfo?
        
        private init(empty: String?, movie: MovieInfo?) {
            self.empty = empty
            self.movie = movie
        }
        
        init(empty: String) {
            self.init(empty: empty, movie: nil)
        }
        
        init(movie: MovieInfo) {
            self.init(empty: nil, movie: movie)
        }
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func emptyCellRegistrationHandler(cell: EmptyCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func searchResultCellRegistrationHandler(cell: MovieListCollectionViewCell, indexPath: IndexPath, item: MovieInfo) {
        cell.configure(with: item)
        cell.likeButton.addTarget(self, action: #selector(likedButtonTapped), for: .touchUpInside)
    }
    
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        if movies.isEmpty {
            let items = [Item(empty: "원하는 검색결과를 찾지 못했습니다")]
            snapshot.appendItems(items, toSection: .empty)
        } else {
            let items = movies.map{ movie in
                let isLiked = likedMovies.contains(where: { $0.id == movie.id })
                let movieInfo = MovieInfo(movie: movie, isLiked: isLiked)
                return Item(movie: movieInfo)
            }
            snapshot.appendItems(items, toSection: .searchResults)
        }
        dataSource.apply(snapshot)
    }
    
    func updateSnapshot(newItems newMovies: [Movie], after index: Int) {
        let items = newMovies.map{ movie in
            let isLiked = likedMovies.contains(where: { $0.id == movie.id })
            let movieInfo = MovieInfo(movie: movie, isLiked: isLiked)
            return Item(movie: movieInfo)
        }
        guard let afterItem = snapshot.itemIdentifiers(inSection: .searchResults).last else { return }
        snapshot.insertItems(items, afterItem: afterItem)
        dataSource.apply(snapshot)
    }
}

//MARK: - CollectionView Delegate
extension MovieSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController(movie: movies[indexPath.item])
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let searchWord = searchBar.text,
              let totalPage else { return }
        
        if currentPage <= totalPage && indexPath.item == (movies.count - 2) {
            loadSearchResults(query: searchWord, isInitial: false)
        }
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
        guard let query = searchBar.text, currentSearchWord != query else { return }
        currentSearchWord = query
        loadSearchResults(query: query)
        let recentSearch = RecentSearch(search: query, date: Date())
        updateRecentResults(recentSearch)
    }
}
