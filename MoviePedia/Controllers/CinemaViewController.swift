//
//  CinemaViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import UIKit

final class CinemaViewController: BaseViewController {
    
    private let profileInfoView = ProfileInfoView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let recentSearchesRemoveAllButton = UIButton()
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private var recentSearches: [String] = ["스파이더맨1", "어매이징 스파이더맨", "어매이징 스파이더맨2", "스파이더맨2"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
        configureCollectionViewDataSource()
    }
    
    @objc func presentProfileEditVC() {
        let profileNicknameEditVC = ProfileNicknameEditViewController()
        present(profileNicknameEditVC, animated: true)
    }
}

//MARK: - Configuration
private extension CinemaViewController {
    func configureViews() {
        profileInfoView.userInfoButton.addTarget(self, action: #selector(presentProfileEditVC), for: .touchUpInside)
        collectionView.backgroundColor = .clear
        
        recentSearchesRemoveAllButton.setTitle("전체 삭제", for: .normal)
        recentSearchesRemoveAllButton.setTitleColor(.moviepedia_point, for: .normal)
    }
    
    func configureHierarchy() {
        view.addSubviews(profileInfoView, collectionView)
    }
    
    func configureConstraints() {
        profileInfoView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileInfoView.snp.bottom).offset(8)
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configureCollectionViewDataSource() {
        let emptyRecentSearchCellRegistration = UICollectionView.CellRegistration(handler: emptyResentSearchCellRegisterHandler)
        let recentSearchCellRegistration = UICollectionView.CellRegistration(handler: recentSearchCellRegidtrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown Section")
            }
            var cell: UICollectionViewCell
            
            switch section {
            case .emptyRecentSearch:
                cell = collectionView.dequeueConfiguredReusableCell(using: emptyRecentSearchCellRegistration, for: indexPath, item: "최근 검색어 내역이 없습니다.")
            case .recentSeach:
                cell = collectionView.dequeueConfiguredReusableCell(using: recentSearchCellRegistration, for: indexPath, item: itemIdentifier)
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
        case .recentSeach:
            return sectionForRecentSearch()
        }
    }
    
    func sectionForEmptyRecentSearch() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [ titleBoundarySupplementaryItem() ]
        return section
    }
    
    func sectionForRecentSearch() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .estimated(100.0), heightDimension: .absolute(35))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func sectionForTodayMovie() -> NSCollectionLayoutSection  {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .estimated(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    func titleBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: "title-element-kind", alignment: .top)
    }
}

//MARK: - DataSource
extension CinemaViewController {
    enum Section: Int, CaseIterable {
        case emptyRecentSearch
        case recentSeach
//        case todayMovie
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    
    func emptyResentSearchCellRegisterHandler(cell: EmptyCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func recentSearchCellRegidtrationHandler(cell: RecentSearchCollectionViewCell, indexPath: IndexPath, item: String) {
        cell.configure(with: item)
    }
    
    func headerSupplementaryRegistrationHandler(supplementaryView: TitleSupplementaryView, string: String, indexPath: IndexPath) {
        supplementaryView.addRightAccessoryView(recentSearchesRemoveAllButton)
        supplementaryView.configure(with: "최근 검색어")
    }
    
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([.emptyRecentSearch, .recentSeach])
        if recentSearches.isEmpty {
            snapshot.appendItems(["0"], toSection: .emptyRecentSearch)
        } else {
            snapshot.appendItems(recentSearches, toSection: .recentSeach)
        }
        dataSource.apply(snapshot)
    }
}
