//
//  ProfileNicknameViewController.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class ProfileNicknameViewController: UIViewController {
    
    private enum LiteralText: String {
        case buttonTitle = "완료"
        
        var text: String {
            return rawValue
        }
    }
    
    private let profileImageControl = ProfileImageCameraControl()
    private let nicknameTextField = StatusLableTextFieldView()
    private let borderlineButton = BorderLineButton(title: LiteralText.buttonTitle.text)
    private lazy var stackView = UIStackView(arrangedSubviews: [profileImageControl, nicknameTextField, borderlineButton])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
}

//MARK: - Configuration
private extension ProfileNicknameViewController {
    func configureViews() {
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
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageControl.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
    }
}
