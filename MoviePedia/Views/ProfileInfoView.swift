//
//  ProfileInfoView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/28/25.
//

import UIKit
import SnapKit

class ProfileInfoView: UIView {
    
    private let backgroundView = UIView()
    private let profileImageControl = ProfileImageControl(style: .selected)
    let userInfoButton = UIButton()
    private let chevronButton = UIButton()
    private lazy var profileStackView = UIStackView(arrangedSubviews: [profileImageControl, userInfoButton])
    private let movieBoxButton = UIButton()
    
    init() {
        super.init(frame: .zero)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ProfileInfoView {
    func configureViews() {
        backgroundView.cornerRadius()
        backgroundView.backgroundColor = .moviepedia_subbackground
        
        var config = UIButton.Configuration.plain()
        let attributedTitleContainer = AttributeContainer([.font: UIFont.systemFont(ofSize: 16, weight: .heavy), .foregroundColor: UIColor.moviepedia_foreground])
        let attributedSubtitleContainer = AttributeContainer([.font: UIFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: UIColor.moviepedia_tagbackground])
        config.attributedTitle = AttributedString("닉네임", attributes: attributedTitleContainer)
        config.attributedSubtitle = AttributedString("25.01.14 가입", attributes: attributedSubtitleContainer)
        userInfoButton.configuration = config
        
        let image = UIImage(systemName: "chevron.right")
        chevronButton.setImage(image, for: .normal)
        chevronButton.tintColor = .moviepedia_tagbackground
        
        profileStackView.axis = .horizontal
        profileStackView.distribution = .fill
        profileStackView.alignment = .center
        
        var movieBoxConfig = UIButton.Configuration.filled()
        movieBoxConfig.title = "0개인 무비박스 보관 중"
        movieBoxConfig.baseForegroundColor = .moviepedia_foreground
        movieBoxConfig.baseBackgroundColor = .moviepedia_point
        movieBoxConfig.background.cornerRadius = 10
        movieBoxButton.configuration = movieBoxConfig
    }
    
    func configureHierarchy() {
        addSubviews(backgroundView)
        backgroundView.addSubviews(profileStackView, chevronButton, movieBoxButton)
        
    }
    
    func configureConstraints() {
        let inset: CGFloat = 16
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageControl.snp.makeConstraints { make in
            make.width.height.equalTo(70)
        }
        
        profileStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(inset)
        }
        
        chevronButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileStackView)
            make.trailing.equalToSuperview().inset(inset)
        }
        
        movieBoxButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.top.equalTo(profileStackView.snp.bottom).offset(inset)
            make.bottom.horizontalEdges.equalToSuperview().inset(inset)
        }
    }
}
