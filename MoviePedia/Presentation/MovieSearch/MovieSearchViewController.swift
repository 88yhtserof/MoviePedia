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
    
    private var likedMovies: [Movie] { UserDefaultsManager.likedMovies }
    private var currentSearchWord: String?
    private let recenteSearchedWord: String?
    
    var likeButtonSelected: ((Bool, Int) -> Void)?
    
    let viewModel = MovieSearchViewModel()
    
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
        configureCollectionViewDataSource()
        bind()
    }
    
    private func bind() {
        
        viewModel.output.showErrorAlert.lazyBind { [weak self] errorMessage in
            guard let self, let errorMessage else { return }
            self.showErrorAlert(message: errorMessage)
        }
        
        viewModel.output.updateInitialSnapshot.lazyBind { [weak self] movies in
            guard let self, let movies else { return }
            self.updateInitialSnapshot(movies)
        }
        
        viewModel.output.updatePagibleSnapshot.lazyBind { [weak self] newMovies in
            guard let self, let newMovies else { return }
            self.updatePagibleSnapshot(newMovies)
        }
        
        viewModel.input.viewDidLoad.send()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if recenteSearchedWord == nil && (searchBar.text?.isEmpty ?? true) {
            DispatchQueue.main.async() {
                self.searchBar.becomeFirstResponder()
            }
        }
    }
    
    private func updateRecentResults(_ recentSearch: RecentSearch) {
        var recentSearches = UserDefaultsManager.recentSearches
        if let index = recentSearches.firstIndex(where: { $0.search == recentSearch.search }) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(recentSearch)
        UserDefaultsManager.recentSearches = recentSearches
    }
    
    @objc func likedButtonTapped(_ sender: UIButton) {
//        guard let movie = movies.first(where: { $0.id == sender.tag }) else { return }
        
//        if sender.isSelected {
//            UserDefaultsManager.likedMovies.append(movie)
//        } else if let removeIndex = UserDefaultsManager.likedMovies.firstIndex(where: {$0.id == movie.id }) {
//            UserDefaultsManager.likedMovies.remove(at: removeIndex)
//        }
//        likeButtonSelected?(sender.isSelected, movie.id)
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
    
    func configureCollectionViewDataSource() {
        let emptyCellRegisteration = UICollectionView.CellRegistration(handler: emptyCellRegistrationHandler)
        let searchResultsCellRegisteration = UICollectionView.CellRegistration(handler: searchResultCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .empty(let item):
                return collectionView.dequeueConfiguredReusableCell(using: emptyCellRegisteration, for: indexPath, item: item)
            case .movie(let item):
                return collectionView.dequeueConfiguredReusableCell(using: searchResultsCellRegisteration, for: indexPath, item: item)
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
    
    enum Item: Hashable {
        case empty(String)
        case movie(MovieInfo)
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
    }
    
    func updateInitialSnapshot(_ movies: [Movie]) {
        let exsitingMovies = snapshot.itemIdentifiers
        snapshot.deleteItems(exsitingMovies)
        
        if movies.isEmpty {
            let items = [Item.empty("원하는 검색결과를 찾지 못했습니다")]
            snapshot.appendItems(items, toSection: .empty)
            dataSource.apply(snapshot)
        } else {
            updatePagibleSnapshot(movies)
        }
    }
    
    func updatePagibleSnapshot(_ newMovies: [Movie]) {
        let items = newMovies.map{ movie in
            let isLiked = likedMovies.contains(where: { $0.id == movie.id })
            let movieInfo = MovieInfo(movie: movie, isLiked: isLiked)
            return Item.movie(movieInfo)
        }
        snapshot.appendItems(items, toSection: .searchResults)
        dataSource.apply(snapshot)
    }
    
    func updateSnapshot1(newItems newMovies: [Movie], after index: Int) {
        let items = newMovies.map{ movie in
            let isLiked = likedMovies.contains(where: { $0.id == movie.id })
            let movieInfo = MovieInfo(movie: movie, isLiked: isLiked)
            return Item.movie(movieInfo)
        }
        guard let afterItem = snapshot.itemIdentifiers(inSection: .searchResults).last else { return }
        snapshot.insertItems(items, afterItem: afterItem)
        dataSource.apply(snapshot)
    }
}

//MARK: - CollectionView Delegate
extension MovieSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard indexPath.section == 1 else { return }
//        let movieDetailVC = MovieDetailViewController(movie: movies[indexPath.item])
//        movieDetailVC.likeButtonSelected = { (isLiked) in
//            guard let cell = collectionView.cellForItem(at: indexPath) as? MovieListCollectionViewCell else {
//                print("Could not find cell")
//                return
//            }
//            cell.likeButton.isSelected = isLiked
//        }
//        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let searchWord = searchBar.text else { return }
        viewModel.input.willDisplaySearchList.send((searchWord, indexPath.item))
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
        viewModel.input.search.send(query)
        let recentSearch = RecentSearch(search: query, date: Date())
        updateRecentResults(recentSearch)
    }
}
