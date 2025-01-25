//
//  ProfileImageEditViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

class ProfileImageEditViewController: UIViewController {
    
    private let profileImageControl = ProfileImageCameraControl()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    private let profileImageNames = (0...11).map({ String(format: "profile_%d", $0) })

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureHierarchy()
        configureConstraints()
        configureCollectionViewDataSource()
        configureInitial()
    }
}

//MARK: - Configuration
private extension ProfileImageEditViewController {
    func configureViews() {
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
    }
    
    func configureHierarchy() {
        view.addSubviews(profileImageControl, collectionView)
    }
    
    func configureConstraints() {
        profileImageControl.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileImageControl.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configureCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: 1)
            return cell
        })
        
        createSnapshot()
        collectionView.dataSource = dataSource
    }
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 8
        let width: CGFloat = 1/4
        let height: CGFloat = (view.frame.width - (spacing * 3)) / 4
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(width), heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func configureInitial() {
        let selectedItem = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedItem, animated: false, scrollPosition: .top)
    }
}

//MARK: - DiffalbleDataSource
private extension ProfileImageEditViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    func cellRegistrationHandler(cell: ProfileImageCollectionViewCell, indexPath: IndexPath, item: Int) {
        let profileImageName = self.profileImageNames[indexPath.item]
        cell.configue(with: profileImageName)
    }
    
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(profileImageNames)
        dataSource.apply(snapshot)
    }
}

//MARK: - CollectionView Delegate
extension ProfileImageEditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) else {
            print("Could not find cell")
            return
        }
        selectedCell.isSelected.toggle()
        let selectedImage = profileImageNames[indexPath.item]
        profileImageControl.image = UIImage(named: selectedImage)
    }
}
