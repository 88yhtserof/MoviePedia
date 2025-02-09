//
//  ProfileOptionSettingContainerView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/9/25.
//

import UIKit

class ProfileOptionSettingContainerView: UIView {
    
    let titleLabel = UILabel()
    let containerView = UIView()
    
    var view: UIView? {
        didSet {
            guard let view else { return }
            containerView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
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

private extension ProfileOptionSettingContainerView {
    func configureViews() {
        titleLabel.textColor = .moviepedia_foreground
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    func configureHierarchy() {
        addSubviews(titleLabel, containerView)
    }
    
    func configureConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.equalTo(100)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing)
        }
    }
}
