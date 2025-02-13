//
//  MovieDetailViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit
import SnapKit
import Kingfisher

final class MovieDetailViewController: BaseViewController {
    
    private let likeButton = LikeSelectedButton()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private var likedMovies: [Movie] { UserDefaultsManager.likedMovies }
    
    let viewModel = MovieDetailViewModel()
    
    var likeButtonSelected: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarachy()
        configureConstraints()
        configureCollectionViewDataSource()
        bind()
    }
    
    private func bind() {
        
        viewModel.output.configureInitialViewData.lazyBind { [weak self] movie in
            print("Output configureInitialViewData bind")
            guard let self, let movie else { return }
            navigationItem.title = movie.title
        }
        
        viewModel.output.showErrorAlert.lazyBind { [weak self] errorMessage in
            print("Output showErrorAlert bind")
            guard let self, let errorMessage else { return }
            self.showErrorAlert(message: errorMessage)
        }
        
        viewModel.output.createSnapshot.lazyBind { [weak self] movieDetail in
            print("Ouytput createSnapshot bind")
            guard let self, let movieDetail else { return }
            self.createSnapshot(movieDetail)
        }
        
        viewModel.input.viewDidLoad.send()
    }
    
    @objc func likedButtonTapped(_ sender: UIButton) {
//        likeButtonSelected?(sender.isSelected)
//        
//        if sender.isSelected {
//            UserDefaultsManager.likedMovies.append(movie)
//        } else if let removeIndex = UserDefaultsManager.likedMovies.firstIndex(where: {$0.id == movie.id }) {
//            UserDefaultsManager.likedMovies.remove(at: removeIndex)
//        }
    }
}

//MARK: - Configuration
private extension MovieDetailViewController {
    func configureViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
        
//        let isLiked = likedMovies.contains(where: { $0.id == movie.id })
//        likeButton.isSelected = isLiked
        likeButton.addTarget(self, action: #selector(likedButtonTapped), for: .touchUpInside)
        
        collectionView.backgroundColor = .moviepedia_background
        collectionView.delegate = self
    }
    
    func configureHierarachy() {
        view.addSubviews(collectionView)
    }
    
    func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configureCollectionViewDataSource() {
        let backdropCellRegistration = UICollectionView.CellRegistration(handler: backdropCellRegistrationHandler)
        let synopsisCellRegistration = UICollectionView.CellRegistration(handler: synopsisCellRegistrationHandler)
        let castCellRegistration = UICollectionView.CellRegistration(handler: castCellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            var cell: UICollectionViewCell
            
            switch itemIdentifier {
            case .backdrop(let value):
                cell = collectionView.dequeueConfiguredReusableCell(using: backdropCellRegistration, for: indexPath, item: value.value)
            case .synopsis(let value):
                cell = collectionView.dequeueConfiguredReusableCell(using: synopsisCellRegistration, for: indexPath, item: value.value)
            case .cast(let value):
                cell = collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: value.value)
            case .poster(let value):
                cell = collectionView.dequeueConfiguredReusableCell(using: backdropCellRegistration, for: indexPath, item: value.value)
            }
            
            return cell
        })
        
        let backdropFooterSupplementaryProvider = UICollectionView.SupplementaryRegistration(elementKind: "layout-footer-element-kind", handler: movieDeatilInfoSupplemetaryRegistrationHandler)
        let headerSupplementaryProvider = UICollectionView.SupplementaryRegistration(elementKind: "title-element-kind", handler: headerSupplementaryRegistrationHandler)
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case "title-element-kind":
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementaryProvider, for: indexPath)
            case "layout-footer-element-kind":
                return collectionView.dequeueConfiguredReusableSupplementary(using: backdropFooterSupplementaryProvider, for: indexPath)
            default:
                return UICollectionReusableView()
            }
        }
        
        collectionView.dataSource = dataSource
    }
}

//MARK: - CollectionView DataSource
private extension MovieDetailViewController {
    
    typealias Section = MovieDetailViewModel.Section
    typealias Item = MovieDetailViewModel.Item
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func backdropCellRegistrationHandler(cell: ImageCollectionCell, indexPath: IndexPath, item: Image) {
        if let path = item.file_path,
           let imageURL = URL(string: ImageNetworkAPI.original.endPoint + path) {
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: imageURL,
                                       options: [.transition(.fade(1.2))])
        }
    }
    
    func synopsisCellRegistrationHandler(cell: TextCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.text = item
        cell.numberOfLines = 3
    }
    
    func castCellRegistrationHandler(cell: CastCollectionViewCell, indexPath: IndexPath, item: Credit) {
        cell.configure(with: item)
    }
    
    func movieDeatilInfoSupplemetaryRegistrationHandler(supplementaryView: MovieDetailInfoSupplementaryView, string: String, indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let (dateStr, ratingStr, genreStr) = viewModel.output.configureMovieDetailInfo.value else { return }
            supplementaryView.configure(with: [dateStr, ratingStr, genreStr])
        }
    }
    
    func headerSupplementaryRegistrationHandler(supplementaryView: TitleSupplementaryView, string: String, indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section")
        }
        
        switch section {
        case .backdrop:
            return
        case .synopsis:
            let moreButton = MoreButton()
            moreButton.tag = indexPath.item
            moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
            supplementaryView.addRightAccessoryView(moreButton)
            supplementaryView.configure(with: section.header!)
        case .cast:
            supplementaryView.configure(with: section.header!)
        case .poster:
            supplementaryView.configure(with: section.header!)
        }
    }
    
    @objc func moreButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(item: sender.tag, section: 1)
        guard let cell = collectionView.cellForItem(at: indexPath) as? TextCollectionViewCell else {
            print("Could not find cell")
            return
        }
        
        if sender.isSelected {
            cell.numberOfLines = 0
        } else {
            cell.numberOfLines = 3
        }
        dataSource.apply(snapshot)
    }
    
    func createSnapshot(_ movieDeatil: MovieDetailViewModel.MovieDetail) {
        
        snapshot = Snapshot()
        snapshot.appendSections([.backdrop, .synopsis, .cast, .poster])
        snapshot.appendItems(movieDeatil.backdropItems, toSection: .backdrop)
        snapshot.appendItems(movieDeatil.synopsysItems, toSection: .synopsis)
        snapshot.appendItems(movieDeatil.creditItems, toSection: .cast)
        snapshot.appendItems(movieDeatil.posterItems, toSection: .poster)
        dataSource.apply(snapshot)
    }
    

}

//MARK: - CollectionView Delegate
extension MovieDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let indexPathForBackdrop = IndexPath(item: 0, section: 0)
            let supplementaryView = collectionView.supplementaryView(forElementKind: "layout-footer-element-kind", at: indexPathForBackdrop)
                        
            guard let movieInfoView = supplementaryView as? MovieDetailInfoSupplementaryView else { return }
            let backdropCount = viewModel.backdrops.count
            
            if movieInfoView.pageControl.numberOfPages != 5
               || movieInfoView.pageControl.numberOfPages != backdropCount {
                movieInfoView.pageControl.numberOfPages = backdropCount > 5 ? 5 : backdropCount
            }
            movieInfoView.pageControl.currentPage = indexPath.item
        }
    }
}


//MARK: - CollectionView Layout
private extension MovieDetailViewController {
    func layout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProviderHandler)
    }
    
    func sectionProviderHandler(sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        guard let section = Section(rawValue: sectionIndex) else {
            fatalError("Unknown section")
        }
        
        switch section {
        case .backdrop:
            return sectionForBackdrop()
        case .synopsis:
            return sectionForSynopsys()
        case .cast:
            return sectionForCast()
        case .poster:
            return sectionForPoster()
        }
    }
    
    func sectionForBackdrop() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [movieDetailInfoSupplementaryItem()]
        
        return section
    }
    
    func sectionForSynopsys() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [titleBoundarySupplementaryItem()]
        return section
    }
    
    func sectionForCast() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .estimated(130))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [titleBoundarySupplementaryItem()]
        return section
    }
    
    func sectionForPoster() -> NSCollectionLayoutSection {
        let height: CGFloat = 200
        let width: CGFloat = (3.0 * height) / 4.0
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [titleBoundarySupplementaryItem()]
        return section
    }
    
    func movieDetailInfoSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: "layout-footer-element-kind", alignment: .bottom)
    }
    
    func titleBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: "title-element-kind", alignment: .top)
    }
}
