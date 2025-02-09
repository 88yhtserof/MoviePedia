//
//  ProfileNicknameViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class ProfileNicknameEditViewController: BaseViewController {
    
    private enum LiteralText: String {
        case buttonTitle = "완료"
        case placeholder = "예) 무피아"
        case statusText = "사용할 수 있는 닉네임이에요"
        
        var text: String {
            return rawValue
        }
    }
    
    private let profileImageControl = ProfileImageCameraControl()
    private let nicknameTextField = StatusLableTextFieldView()
    private let profileMBTIOptionView = ProfileMBTIOptionView()
    private let profileMBTIOptionSettingContainerView = ProfileOptionSettingContainerView()
    private let doneButton = BorderLineButton(title: LiteralText.buttonTitle.text)
    private lazy var stackView = UIStackView(arrangedSubviews: [profileImageControl, nicknameTextField, profileMBTIOptionSettingContainerView])
    
    private var isEditedMode: Bool
    
    let viewModel = ProfileNicknameEditViewModel()
    
    var saveProfileHandler: ((User) -> Void)?
    
    init(user: User? = nil, isEditedMode: Bool = false) {
        self.isEditedMode = isEditedMode
        super.init(nibName: nil, bundle: nil)
        configureInitialData(user)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func bind() {
        
        viewModel.outputProfileImageName.lazyBind { [weak self] profileImageName in
            print("outputProfileImageName bind: \(profileImageName)")
            guard let self else { return }
            self.profileImageControl.image = UIImage(named: profileImageName)
        }
        
        viewModel.outputNicknameValidationResult.lazyBind { [weak self] result in
            print("outputNicknameValidationResult bind: \(result)")
            guard let self else { return }
            
            var isEnabled: Bool
            
            switch result {
            case .success(let statusText):
                self.nicknameTextField.statusText = statusText
                self.nicknameTextField.statusColor = .moviepedia_point
                isEnabled = true
            case .failure(let error):
                self.nicknameTextField.statusText = error.description
                self.nicknameTextField.statusColor = .moviepedia_error
                isEnabled = false
            }
            
            if isEditedMode {
                self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
            } else {
                doneButton.isUserInteractionEnabled = isEnabled
            }
        }
        
        viewModel.inputViewDidLoad.send()
    }
    
    @objc func dismissBarButtonItemTapped() {
        dismiss(animated: true)
    }
    
    @objc func saveBarButtonItemTapped() {
//        guard let user = saveProfileData() else { return }
//        saveProfileHandler?(user)
//        dismiss(animated: true)
    }
    
    @objc func profileImageControlDidTapped() {
        let profileImageNumber = viewModel.outputProfileImageNumber.value
        let profileImageEditVC = ProfileImageEditViewController()
        profileImageEditVC.viewModel.inputProfileImageNumber.send(profileImageNumber)
        profileImageEditVC.viewModel.outputSendProfileImageNumber.lazyBind{ [weak self] number in
            print("outputSendProfileImageNumber bind")
            guard let self else { return }
            self.viewModel.inputProfileImageNumber.send(number)
            
        }
        self.navigationController?.pushViewController(profileImageEditVC, animated: true)
    }
    
    @objc func nicknameTextFieldEditingChanged(_ sender: UITextField) {
        viewModel.inputEditingChangedNickname.send(sender.text)
    }
    
    @objc func doneButtonDidTapped() {
//        saveProfileData()
        UserDefaultsManager.isOnboardingNotNeeded = true
        
        let mainVC = MainTabBarViewController()
        switchRootViewController(rootViewController: mainVC)
    }
    
//    @discardableResult
//    private func saveProfileData() -> User? {
//        guard let nickname else { return nil }
//        let profileImageName = String(format: "profile_%d", profileImageNumber)
//        let user = User(createdAt: Date(), nickname: nickname, profileImage: profileImageName)
//        UserDefaultsManager.user = user
//        return user
//    }
}




//MARK: - Configuration
private extension ProfileNicknameEditViewController {
    
    private func configureInitialData(_ user: User?) {
        guard let user else {
            navigationItem.title = "프로필 설정"
            return
        }
        
        navigationItem.title = "프로필 편집"
        let dismissBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissBarButtonItemTapped))
        let saveBarButtonItem = UIBarButtonItem(title: "저장", image: nil, target: self, action: #selector(saveBarButtonItemTapped))
        
        navigationItem.leftBarButtonItem = dismissBarButtonItem
        navigationItem.rightBarButtonItem = saveBarButtonItem
        doneButton.isHidden = true
        nicknameTextField.textField.text = user.nickname
//        nickname = user.nickname
        
        if let image = user.profileImage.components(separatedBy: "_").last,
           let number = Int(image) {
//            profileImageNumber = number
        }
    }
    
    func configureViews() {
        profileImageControl.addTarget(self, action: #selector(profileImageControlDidTapped), for: .touchUpInside)
        
        nicknameTextField.textField.placeholder = LiteralText.placeholder.text
        nicknameTextField.textField.textField.addTarget(self, action: #selector(nicknameTextFieldEditingChanged), for: .editingChanged)
        
        
        profileMBTIOptionSettingContainerView.titleLabel.text = "MBTI"
        profileMBTIOptionSettingContainerView.view = profileMBTIOptionView
        
        doneButton.isUserInteractionEnabled = false
        doneButton.addTarget(self, action: #selector(doneButtonDidTapped), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
    }
    
    func configureHierarchy() {
        view.addSubviews(profileImageControl, stackView, doneButton)
    }
    
    func configureConstraints() {
        profileImageControl.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageControl.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(5)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(-30)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
    }
}
