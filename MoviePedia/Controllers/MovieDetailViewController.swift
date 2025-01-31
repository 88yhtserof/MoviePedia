//
//  MovieDetailViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit
import SnapKit

final class MovieDetailViewController: BaseViewController {
    
    let imageList = [
        "/f3dmjpDiOmy047WsQMY03pnNMu1.jpg",
        "/y9HpPnZUkygFishCcYDOpzHgdD5.jpg",
        "/faawswmpK7mGhPtiVjdPWVJ6Vld.jpg"
    ]
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarachy()
        configureConstraints()
        configureCollectionViewDataSource()
    }
}

//MARK: - Configuration
private extension MovieDetailViewController {
    func configureViews() {
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
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: backdropCellRegistration, for: indexPath, item: itemIdentifier.backdrop)
            return cell
        })
        
        let backdropFooterSupplementaryProvider = UICollectionView.SupplementaryRegistration(elementKind: "layout-footer-element-kind", handler: movieDeatilInfoSupplemetaryRegistrationHandler)
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: backdropFooterSupplementaryProvider, for: indexPath)
        }
        
        createSnapshot()
        collectionView.dataSource = dataSource
    }
}

//MARK: - CollectionView DataSource
private extension MovieDetailViewController {
    enum Section: Int {
        case backdrop
//        case synopsys
//        case cast
//        case poster
    }
    
    struct Item: Hashable {
        let backdrop: String?
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func backdropCellRegistrationHandler(cell: ImageCollectionCell, indexPath: IndexPath, item: String) {
        let path = imageList[indexPath.item]
        if let imageURL = URL(string: TMDBNetworkAPI.imageBaseURL + path) {
            cell.imageView.kf.setImage(with: imageURL)
        }
    }
    
    func movieDeatilInfoSupplemetaryRegistrationHandler(supplementaryView: MovieDetailInfoSupplementaryView, string: String, indexPath: IndexPath) {
        if indexPath.section == 0 {
            let dateStr = "2024-12-24"
            let ratingStr = "8.0"
            let genreStr = String(format: "%@, %@", "액션", "스릴러")
            supplementaryView.configure(with: [dateStr, ratingStr, genreStr])
//            supplementaryView.pageControlHandle
        }
    }
    
    func createSnapshot() {
        let items = imageList.map{ Item(backdrop: $0) }
        snapshot = Snapshot()
        snapshot.appendSections([.backdrop])
        snapshot.appendItems(items, toSection: .backdrop)
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
//        case .synopsys:
//            return sectionForSynopsys()
//        case .cast:
//            return sectionForCast()
//        case .poster:
//            return sectionForPoster()
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
    
//    func sectionForSynopsys() -> NSCollectionLayoutSection {
//        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
//        let item = NSCollectionLayoutItem(layoutSize: size)
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        return section
//    }
//    
//    func sectionForCast() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute(50))
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute(120))
//        
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .continuous
//        return section
//    }
//    
//    func sectionForPoster() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .estimated(100))
//        
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        return section
//    }
    
    func movieDetailInfoSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: "layout-footer-element-kind", alignment: .bottom)
    }
}
