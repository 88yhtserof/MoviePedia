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
    
    let posterList = [
        "/1hEC2ld1nLS6i8ump3ecPHqZ3OR.png",
        "/hwmCH4LefEnjoeUYMKd0zhhjUcW.png",
        "/888Fm41DNgQ4PtNECv1IEKsJXjk.png"
    ]
    
    let cast = [Cast(name: "김다미", character: "Koo Ja-yoon", profile_path: "/nRGhwfuWqcTMoTmnhK4XmcRkZ6B.jpg"), Cast(name: "조민수", character: "Dr. Baek", profile_path: "/1dC0ZRTWlvFEcDk4O6peI97zsVM.jpg"), Cast(name:  "박희순", character: "Mr. Choi", profile_path: "/s2SSzvlsSfCPP5EXhCoWUr8970F.jpg"), Cast(name: "고민시", character: "Do Myeong-hee", profile_path: "/w6GAqYilB3ej5Had7rfc6grLHPB.jpg"), Cast(name: "최정우", character: "Koo Seong-hwan", profile_path: "/doHUwUDRML1uo0PVVRXblGAJhN3.jpg"), Cast(name: "오미희", character: "Koo's wife", profile_path: "/js6ztmJnh3hlLEDm9nX6P3b1zbO.jpg"), Cast(name: "정다은", character: "Long Hair", profile_path: "/yAqywl2JDji5H9lxpdmOFIVvQTY.jpg")]
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        navigationItem.title = movie.title
        
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
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section")
            }
            var cell: UICollectionViewCell
            switch section {
            case .backdrop:
                cell = collectionView.dequeueConfiguredReusableCell(using: backdropCellRegistration, for: indexPath, item: itemIdentifier.backdrop)
            case .synopsys:
                cell = collectionView.dequeueConfiguredReusableCell(using: synopsisCellRegistration, for: indexPath, item: itemIdentifier.synopsis)
            case .cast:
                cell = collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: itemIdentifier.cast)
            case .poster:
                cell = collectionView.dequeueConfiguredReusableCell(using: backdropCellRegistration, for: indexPath, item: itemIdentifier.poster)
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
        
        createSnapshot()
        collectionView.dataSource = dataSource
    }
}

//MARK: - CollectionView DataSource
private extension MovieDetailViewController {
    enum Section: Int {
        case backdrop
        case synopsys
        case cast
        case poster
        
        var header: String? {
            switch self {
            case .backdrop:
                return nil
            case .synopsys:
                return "Synopsis"
            case .cast:
                return "Cast"
            case .poster:
                return "Poster"
            }
        }
    }
    
    struct Item: Hashable {
        let backdrop: String?
        let synopsis: String?
        let cast: Cast?
        let poster: String?
        
        private init(backdrop: String?, synopsis: String?, cast: Cast?, poster: String?) {
            self.backdrop = backdrop
            self.synopsis = synopsis
            self.cast = cast
            self.poster = poster
        }
        
        init(backdrop: String) {
            self.init(backdrop: backdrop, synopsis: nil, cast: nil, poster: nil)
        }
        
        init(synopsis: String) {
            self.init(backdrop: nil, synopsis: synopsis, cast: nil, poster: nil)
        }
        
        init(cast: Cast) {
            self.init(backdrop: nil, synopsis: nil, cast: cast, poster: nil)
        }
        
        init(poster: String) {
            self.init(backdrop: nil, synopsis: nil, cast: nil, poster: poster)
        }
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func backdropCellRegistrationHandler(cell: ImageCollectionCell, indexPath: IndexPath, item: String) {
        let path = imageList[indexPath.item]
        if let imageURL = URL(string: TMDBNetworkAPI.imageBaseURL + path) {
            cell.imageView.kf.setImage(with: imageURL)
        }
    }
    
    func synopsisCellRegistrationHandler(cell: TextCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.text = item
        cell.numberOfLines = 3
    }
    
    func castCellRegistrationHandler(cell: CastCollectionViewCell, indexPath: IndexPath, item: Cast) {
        cell.configure(with: item)
    }
    
    func movieDeatilInfoSupplemetaryRegistrationHandler(supplementaryView: MovieDetailInfoSupplementaryView, string: String, indexPath: IndexPath) {
        if indexPath.section == 0 {
            // TODO: - Movie 작업 모델로 분리
            let dateStr = movie.release_date ?? "_"
            let ratingStr = String(movie.vote_average ?? 0.0)
            let genres = (movie.genre_ids?.prefix(2).compactMap{ Genre(rawValue: $0)?.name_kr }) ?? []
            let genreStr = genres.joined(separator: ", ")
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
        case .synopsys:
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
    
    func createSnapshot() {
        let backdropItems = imageList.map{ Item(backdrop: $0) }
        let synopsysItems = [Item(synopsis: movie.overview ?? "")]
        let castItems = cast.map{ Item(cast: $0) }
        let posterItems: [Item] = posterList.map{ Item(poster: $0) }
        
        snapshot = Snapshot()
        snapshot.appendSections([.backdrop, .synopsys, .cast, .poster])
        snapshot.appendItems(backdropItems, toSection: .backdrop)
        snapshot.appendItems(synopsysItems, toSection: .synopsys)
        snapshot.appendItems(castItems, toSection: .cast)
        snapshot.appendItems(posterItems, toSection: .poster)
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
        case .synopsys:
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
