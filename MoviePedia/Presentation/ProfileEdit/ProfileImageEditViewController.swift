//
//  ProfileImageEditViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class ProfileImageEditViewController: BaseViewController {
    
    private let profileImageControl = ProfileImageCameraControl()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private var isEditedMode: Bool
    
    let viewModel = ProfileImageEditViewModel()
    
    init(isEditedMode: Bool = false) {
        print("ProfileImageEditViewController init")
        self.isEditedMode = isEditedMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // 호출이 되고 있지 않음
        print("ProfileImageEditViewController deinit")
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
        
        viewModel.input.viewDidLoad.send()
        
        viewModel.output.profileImageName.bind { [weak self] profileImageName in
            print("outputProfileImageName bind: \(profileImageName)")
            guard let self else { return }
            self.profileImageControl.image = UIImage(named: profileImageName)
        }
        
        viewModel.output.initSelectedProfileImageItem.bind { [weak self] profileImageNumber in
            print("outputInitSelectedProfileImageItem bind: \(profileImageNumber)")
            guard let self else { return }
            let selectedItem = IndexPath(item: profileImageNumber, section: 0)
            self.collectionView.selectItem(at: selectedItem, animated: false, scrollPosition: .top)
        }
    }
}

//MARK: - Configuration
private extension ProfileImageEditViewController {
    func configureViews() {
        navigationItem.title = isEditedMode ? "프로필 이미지 편집" : "프로필 이미지 설정"
        
        backBarButtonItemAction = { [weak self] in
            guard let self else { return }
            self.viewModel.input.popPreviousVC.send()
        }
        
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
}

//MARK: - DiffalbleDataSource
private extension ProfileImageEditViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    func cellRegistrationHandler(cell: ProfileImageCollectionViewCell, indexPath: IndexPath, item: Int) {
        let profileImageName = viewModel.profileImageNames[indexPath.item]
        cell.configue(with: profileImageName)
    }
    
    func createSnapshot() {
        let items = viewModel.profileImageNames
        snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
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
        viewModel.input.profileImageNumber.send(indexPath.item)
    }
}
