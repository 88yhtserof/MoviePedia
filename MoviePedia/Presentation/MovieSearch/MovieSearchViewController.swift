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
    
    let viewModel = MovieSearchViewModel()
    
    init() {
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
            print("Output showErrorAlert bind")
            guard let self, let errorMessage else { return }
            self.showErrorAlert(message: errorMessage)
        }
        
        viewModel.output.updateInitialSnapshot.lazyBind { [weak self] movies in
            print("Output updateInitialSnapshot bind")
            guard let self, let movies else { return }
            self.updateInitialSnapshot(movies)
        }
        
        viewModel.output.updatePagibleSnapshot.lazyBind { [weak self] newMovies in
            print("Output updatePagibleSnapshot bind")
            guard let self, let newMovies else { return }
            self.updatePagibleSnapshot(newMovies)
        }
        
        // 아래 로직 구현보다 이전 화면에서 검색어를 전달하는 시점이 더 먼저이기 때문에 lazy하게 선언하면 안 됨
        viewModel.output.setReceivedSearchWord.bind { [weak self] receivedSearchWord in
            print("Output setReceivedSearchWord bind")
            guard let self, let receivedSearchWord else { return }
            self.searchBar.text = receivedSearchWord
        }
        
        viewModel.output.becomeFirstResponder.lazyBind { [weak self] in
            print("Output becomeFirstResponder bind")
            guard let self else { return }
            DispatchQueue.main.async() {
                self.searchBar.becomeFirstResponder()
            }
        }
        
        viewModel.input.viewDidLoad.send()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.input.checkRecentSearchMovie.send(searchBar.text)
    }
    
    @objc func likedButtonTapped(_ sender: UIButton) {
        viewModel.input.didTapLikesButton.send((sender.tag, sender.isSelected))
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
    
    func updateSnapshot(newItems newMovies: [Movie], after index: Int) {
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
        let existingSearchWord = viewModel.output.updateRecentSearches.value
        guard let query = searchBar.text,
              existingSearchWord != query
        else { return }
        viewModel.input.search.send(query)
    }
}
