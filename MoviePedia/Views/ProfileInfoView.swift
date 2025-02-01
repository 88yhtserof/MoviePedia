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
    private let userInfoButton = UIButton()
    private let chevronButton = UIButton()
    let profileControlView = UIControl()
    private let movieBoxButton = UIButton()
    
    var user: User {
        didSet {
            profileImageControl.image = UIImage(named: user.profileImage)
            updateUserNickname()
        }
    }
    private let likedMoviesCount: Int
    
    init(user: User, likedMoviesCount: Int) {
        self.user = user
        self.likedMoviesCount = likedMoviesCount
        super.init(frame: .zero)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLikedMoviesCount(_ count: Int) {
        var config = movieBoxButton.configuration
        config?.title = String(format: "%d개인 무비박스 보관 중", count)
        movieBoxButton.configuration = config
    }
    
    func updateUserNickname() {
        var config = userInfoButton.configuration!
        let attributedTitleContainer = AttributeContainer([.font: UIFont.systemFont(ofSize: 16, weight: .heavy), .foregroundColor: UIColor.moviepedia_foreground])
        config.attributedTitle = AttributedString(user.nickname, attributes: attributedTitleContainer)
        userInfoButton.configuration = config
    }
}

//MARK: - Configuration
private extension ProfileInfoView {
    func configureViews() {
        backgroundView.cornerRadius()
        backgroundView.backgroundColor = .moviepedia_subbackground
        
        profileImageControl.image = UIImage(named: user.profileImage)
        profileImageControl.isUserInteractionEnabled = false
        
        var config = UIButton.Configuration.plain()
        let attributedTitleContainer = AttributeContainer([.font: UIFont.systemFont(ofSize: 16, weight: .heavy), .foregroundColor: UIColor.moviepedia_foreground])
        let attributedSubtitleContainer = AttributeContainer([.font: UIFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: UIColor.moviepedia_tagbackground])
        let dateStr = String(format: "%@ 가입", DateFormatterManager.shared.string(from: user.createdAt, format: .userCreatedAt))
        config.attributedTitle = AttributedString(user.nickname, attributes: attributedTitleContainer)
        config.attributedSubtitle = AttributedString(dateStr, attributes: attributedSubtitleContainer)
        userInfoButton.configuration = config
        userInfoButton.isUserInteractionEnabled = false
        
        let image = UIImage(systemName: "chevron.right")
        chevronButton.setImage(image, for: .normal)
        chevronButton.tintColor = .moviepedia_tagbackground
        
        var movieBoxConfig = UIButton.Configuration.filled()
        movieBoxConfig.title = String(format: "%d개인 무비박스 보관 중", likedMoviesCount)
        movieBoxConfig.baseForegroundColor = .moviepedia_foreground
        movieBoxConfig.baseBackgroundColor = .moviepedia_point
        movieBoxConfig.background.cornerRadius = 10
        movieBoxButton.configuration = movieBoxConfig
    }
    
    func configureHierarchy() {
        addSubviews(backgroundView)
        backgroundView.addSubviews(profileControlView, chevronButton, movieBoxButton)
        profileControlView.addSubviews(profileImageControl, userInfoButton)
    }
    
    func configureConstraints() {
        let horizontalInnset: CGFloat = 14
        let verticalInset: CGFloat = 8
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageControl.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.verticalEdges.leading.equalToSuperview()
        }
        
        userInfoButton.snp.makeConstraints { make in
            make.leading.equalTo(profileImageControl.snp.trailing).offset(8)
            make.centerY.equalTo(profileImageControl)
        }
        
        profileControlView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(verticalInset)
            make.leading.equalToSuperview().inset(horizontalInnset)
            make.trailing.equalTo(movieBoxButton)
        }
        
        chevronButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileControlView)
            make.trailing.equalToSuperview().inset(horizontalInnset)
        }
        
        movieBoxButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalTo(profileControlView.snp.bottom).offset(verticalInset)
            make.horizontalEdges.equalToSuperview().inset(horizontalInnset)
            make.bottom.equalToSuperview().inset(verticalInset)
        }
    }
}
