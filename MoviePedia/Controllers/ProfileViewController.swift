//
//  ProfileViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import UIKit
import SnapKit

class ProfileViewController: BaseViewController {
    
    private lazy var profileInfoView = ProfileInfoView(user: user, likedMoviesCount: likedMovies.count)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    private var user: User { UserDefaultsManager.user! }
    private var likedMovies: [Movie] { UserDefaultsManager.likedMovies }
    
    let items = [ "자주 묻는 질문", "1:1 문의", "알림 설정", "탈퇴하기"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
        configureCollectionViewDataSource()
    }
    
    @objc func presentProfileEditVC() {
        let profileNicknameEditVC = ProfileNicknameEditViewController(user: user, isEditedMode: true)
        let profileNicknameEditNC = UINavigationController(rootViewController: profileNicknameEditVC)
        if let sheet = profileNicknameEditNC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        profileNicknameEditVC.saveProfileHandler = { user in
            self.profileInfoView.user = user
        }
        present(profileNicknameEditNC, animated: true)
    }
}

//MARK: - Configuration
private extension ProfileViewController {
    func configureViews() {
        navigationItem.title = "설정"
        
        profileInfoView.profileControlView.addTarget(self, action: #selector(presentProfileEditVC), for: .touchUpInside)
        
        collectionView.alwaysBounceVertical = false
        collectionView.delegate = self
    }
    
    func configureHierarchy() {
        view.addSubviews(profileInfoView, collectionView)
    }
    
    func configureConstraints() {
        profileInfoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileInfoView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
    }
    
    func configureCollectionViewDataSource() {
        let cellRegidtration = UICollectionView.CellRegistration(handler: cellRegidtrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegidtration, for: indexPath, item: itemIdentifier)
        })
        
        createSnapshot()
        collectionView.dataSource = dataSource
    }
}

//MARK: - CollectionView DataSource
extension ProfileViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    func cellRegidtrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, item: String) {
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = item
        contentConfig.textProperties.font = .systemFont(ofSize: 14, weight: .medium)
        contentConfig.textProperties.color = .moviepedia_foreground
        cell.contentConfiguration = contentConfig
        
        cell.backgroundConfiguration?.backgroundColor = .moviepedia_background
        
        cell.separatorLayoutGuide.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
        }
    }
    
    func createSnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
}

//MARK: - CollectionView Layout
private extension ProfileViewController {
    func layout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.separatorConfiguration.color = .moviepedia_subbackground
        config.backgroundColor = .moviepedia_background
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
}

//MARK: - CollectionView Delegate
extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 3 {
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                UserDefaultsManager.reset()
                let onboardingVC = OnboardingViewController()
                self.switchRootViewController(rootViewController: onboardingVC, isNavigationEmbeded: true)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            showAlert(title: "탈퇴하기", message: "탈퇴를 하면 데이터가 모두 초기화됩니다.\n탈퇴 하시겠습니까?", Style: .alert, actions: [cancelAction, okAction])
        }
    }
}
