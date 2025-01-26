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
        
        var text: String {
            return rawValue
        }
    }
    
    private let profileImageControl = ProfileImageCameraControl()
    private let nicknameTextField = StatusLableTextFieldView()
    private let borderlineButton = BorderLineButton(title: LiteralText.buttonTitle.text)
    private lazy var stackView = UIStackView(arrangedSubviews: [profileImageControl, nicknameTextField, borderlineButton])
    
    private var profileImageNumber = (0...11).randomElement()! {
        didSet {
            let imageName = String(format: "profile_%d", profileImageNumber)
            profileImageControl.image = UIImage(named: imageName)
        }
    }
    
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
}

//MARK: - Configuration
private extension ProfileNicknameEditViewController {
    func configureViews() {
        let image = UIImage(named: String(format: "profile_%d", profileImageNumber))
        profileImageControl.image = image
        profileImageControl.addTarget(self, action: #selector(profileImageControlDidTapped), for: .touchUpInside)
        
        nicknameTextField.textField.placeholder = LiteralText.placeholder.text
        
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
