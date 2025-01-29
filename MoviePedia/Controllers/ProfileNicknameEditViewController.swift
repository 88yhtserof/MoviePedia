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
    private let doneButton = BorderLineButton(title: LiteralText.buttonTitle.text)
    private lazy var stackView = UIStackView(arrangedSubviews: [profileImageControl, nicknameTextField, doneButton])
    
    private var profileImageNumber = (0...11).randomElement()! {
        didSet {
            let imageName = String(format: "profile_%d", profileImageNumber)
            profileImageControl.image = UIImage(named: imageName)
        }
    }
    
    private let nicknameValidator = NicknameValidator()
    private var nickname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    @objc func profileImageControlDidTapped() {
        let profileImageEditVC = ProfileImageEditViewController(profileImageNumber: profileImageNumber)
        profileImageEditVC.selectedImageHandler = { selectedImageNumber in
            self.profileImageNumber = selectedImageNumber
        }
        self.navigationController?.pushViewController(profileImageEditVC, animated: true)
    }
    
    @objc func nicknameTextFieldEditingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        
        do {
            nickname = try nicknameValidator.validateNickname(of: text)
            nicknameTextField.statusText = LiteralText.statusText.text
            doneButton.isUserInteractionEnabled = true
        } catch let error as NicknameValidator.ValidationError {
            nicknameTextField.statusText = error.description
            doneButton.isUserInteractionEnabled = false
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    @objc func doneButtonDidTapped() {
        guard let nickname else { return }
        let profileImageName = String(format: "profile_%d", profileImageNumber)
        let user = User(createdAt: Date(), nickname: nickname, profileImage: profileImageName)
        UserDefaultsManager.user = user
        UserDefaultsManager.isOnboardingNotNeeded = true
        
        let mainVC = MainTabBarViewController()
        switchRootViewController(rootViewController: mainVC)
    }
}




//MARK: - Configuration
private extension ProfileNicknameEditViewController {
    func configureViews() {
        let image = UIImage(named: String(format: "profile_%d", profileImageNumber))
        profileImageControl.image = image
        profileImageControl.addTarget(self, action: #selector(profileImageControlDidTapped), for: .touchUpInside)
        
        nicknameTextField.textField.placeholder = LiteralText.placeholder.text
        nicknameTextField.textField.textField.addTarget(self, action: #selector(nicknameTextFieldEditingChanged), for: .editingChanged)
        
        doneButton.isUserInteractionEnabled = false
        doneButton.addTarget(self, action: #selector(doneButtonDidTapped), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
    }
    
    func configureHierarchy() {
        view.addSubviews(profileImageControl, stackView)
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
    }
}
