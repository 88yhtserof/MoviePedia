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
    
    private let networkManager = TMDBNetworkManager.shared
    private var likedMovies: [Movie] { UserDefaultsManager.likedMovies }
    
    private let movie: Movie
    private var backdrops: [Image] = []
    private var posters: [Image] = []
    private var credits: [Credit] = []
    
    var likeButtonSelected: ((Bool) -> Void)?
    
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
        loadMovieDetail()
    }
    
    private func loadMovieDetail() {
        let group = DispatchGroup()
        
        group.enter()
        loadMovieImage() {
            group.leave()
        }

        group.enter()
        loadMovieCredit() {
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.createSnapshot()
        }
    }
    
    private func loadMovieImage(completionHandler: @escaping () -> Void) {
        let request = ImageRequest(movieID: movie.id)
        networkManager.request(api: .image(request)) { [self] (image: ImageResponse) in
            self.backdrops = image.backdrops ?? []
            self.posters = image.posters ?? []
            completionHandler()
        } failureHandler: { error in
            print(error)
        }
    }
    private func loadMovieCredit(completionHandler: @escaping () -> Void) {
        let request = CreditRequest(movieID: movie.id)
        networkManager.request(api: .credit(request)) { [self] (credit: CreditResponse) in
            self.credits = credit.cast ?? []
            completionHandler()
        } failureHandler: { error in
            self.showErrorAlert(message: error.localizedDescription)
        }
    }
    
    @objc func likedButtonTapped(_ sender: UIButton) {
        likeButtonSelected?(sender.isSelected)
        
        if sender.isSelected {
            UserDefaultsManager.likedMovies.append(movie)
        } else if let removeIndex = UserDefaultsManager.likedMovies.firstIndex(where: {$0.id == movie.id }) {
            UserDefaultsManager.likedMovies.remove(at: removeIndex)
        }
    }
}

//MARK: - Configuration
private extension MovieDetailViewController {
    func configureViews() {
        navigationItem.title = movie.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
        
        let isLiked = likedMovies.contains(where: { $0.id == movie.id })
        likeButton.isSelected = isLiked
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
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section")
            }
            var cell: UICollectionViewCell
            switch section {
            case .backdrop:
                cell = collectionView.dequeueConfiguredReusableCell(using: backdropCellRegistration, for: indexPath, item: itemIdentifier.backdrop?.value)
            case .synopsys:
                cell = collectionView.dequeueConfiguredReusableCell(using: synopsisCellRegistration, for: indexPath, item: itemIdentifier.synopsis?.value)
            case .cast:
                cell = collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: itemIdentifier.cast?.value)
            case .poster:
                cell = collectionView.dequeueConfiguredReusableCell(using: backdropCellRegistration, for: indexPath, item: itemIdentifier.poster?.value)
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
        let backdrop: Identifier<Image>?
        let synopsis: Identifier<String>?
        let cast: Identifier<Credit>?
        let poster: Identifier<Image>?
        
        private init(backdrop: Image?, synopsis: String?, cast: Credit?, poster: Image?) {
            self.backdrop = backdrop != nil ? Identifier(value: backdrop!) : nil
            self.synopsis = synopsis != nil ? Identifier(value: synopsis!) : nil
            self.cast = cast != nil ? Identifier(value: cast!) : nil
            self.poster = poster != nil ? Identifier(value: poster!) : nil
        }
        
        init(backdrop: Image) {
            self.init(backdrop: backdrop, synopsis: nil, cast: nil, poster: nil)
        }
        
        init(synopsis: String) {
            self.init(backdrop: nil, synopsis: synopsis, cast: nil, poster: nil)
        }
        
        init(cast: Credit) {
            self.init(backdrop: nil, synopsis: nil, cast: cast, poster: nil)
        }
        
        init(poster: Image) {
            self.init(backdrop: nil, synopsis: nil, cast: nil, poster: poster)
        }
    }
    
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
        let backdropItems = backdrops.prefix(5).map{ Item(backdrop: $0) }
        let synopsysItems = [Item(synopsis: movie.overview ?? "")]
        let creditItems = credits.map{ Item(cast: $0) }
        let posterItems: [Item] = posters.map{ Item(poster: $0) }
        
        snapshot = Snapshot()
        snapshot.appendSections([.backdrop, .synopsys, .cast, .poster])
        snapshot.appendItems(backdropItems, toSection: .backdrop)
        snapshot.appendItems(synopsysItems, toSection: .synopsys)
        snapshot.appendItems(creditItems, toSection: .cast)
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
            if movieInfoView.pageControl.numberOfPages != 5
               || movieInfoView.pageControl.numberOfPages != backdrops.count {
                movieInfoView.pageControl.numberOfPages = backdrops.count > 5 ? 5 : backdrops.count
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
