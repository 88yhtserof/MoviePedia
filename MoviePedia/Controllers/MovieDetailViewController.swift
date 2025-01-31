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
        let synopsisCellRegistration = UICollectionView.CellRegistration(handler: synopsisCellRegistrationHandler)
        
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
//        case cast
//        case poster
        
        var header: String? {
            switch self {
            case .backdrop:
                return nil
            case .synopsys:
                return "Synopsis"
            }
        }
    }
    
    struct Item: Hashable {
        let backdrop: String?
        let synopsis: String?
        
        private init(backdrop: String?, synopsis: String?) {
            self.backdrop = backdrop
            self.synopsis = synopsis
        }
        
        init(backdrop: String) {
            self.init(backdrop: backdrop, synopsis: nil)
        }
        
        init(synopsis: String) {
            self.init(backdrop: nil, synopsis: synopsis)
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
    
    func movieDeatilInfoSupplemetaryRegistrationHandler(supplementaryView: MovieDetailInfoSupplementaryView, string: String, indexPath: IndexPath) {
        if indexPath.section == 0 {
            let dateStr = "2024-12-24"
            let ratingStr = "8.0"
            let genreStr = String(format: "%@, %@", "액션", "스릴러")
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
        let synopsysItems = [Item(synopsis: "’자윤’이 사라진 뒤, 정체불명의 집단의 무차별 습격으로 마녀 프로젝트가 진행되고 있는 ‘아크’가 초토화된다. 그곳에서 홀로 살아남은 ‘소녀’는 생애 처음 세상 밖으로 발을 내딛고 우연히 만난 ‘경희’의 도움으로 농장에서 지내며 따뜻한 일상에 적응해간다. 한편, ‘소녀’가 망실되자 행방을 쫓는 책임자 ‘장’과 마녀 프로젝트의 창시자 ‘백총괄’의 지령을 받고 제거에 나선 본사 요원 ‘조현’, ‘경희’의 농장 소유권을 노리는 조직의 보스 ‘용두’와 상해에서 온 의문의 4인방까지 각기 다른 목적을 지닌 세력이 하나 둘 모여들기 시작하면서 ‘소녀’ 안에 숨겨진 본성이 깨어나는데… 모든 것의 시작, 더욱 거대하고 강력해진 마녀가 온다.")]
        snapshot = Snapshot()
        snapshot.appendSections([.backdrop, .synopsys])
        snapshot.appendItems(backdropItems, toSection: .backdrop)
        snapshot.appendItems(synopsysItems, toSection: .synopsys)
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
    
    func sectionForSynopsys() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [titleBoundarySupplementaryItem()]
        return section
    }
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
    
    func titleBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: "title-element-kind", alignment: .top)
    }
}
