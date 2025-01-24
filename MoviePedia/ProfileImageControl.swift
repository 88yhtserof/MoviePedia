//
//  ProfileImageControl.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

class ProfileImageControl: UIControl {
    
    enum Style {
        case selected
        case unselected
        
        var borderColor: UIColor {
            switch self {
            case .selected:
                return .moviepedia_point
            case .unselected:
                return .moviepedia_subbackground
            }
        }
    }
    
    private var circleBorderView = UIView()
    private let profileImageView = UIImageView()
    
    var image: UIImage? = UIImage(named: "profile_0") {
        didSet {
            profileImageView.image = image
        }
    }
    
    override var isSelected: Bool {
        didSet {
            print(isSelected)
            style = isSelected ? .selected : .unselected
        }
    }
    
    private var style: Style {
        didSet {
            circleBorderView.layer.borderColor = style.borderColor.cgColor
        }
    }
    
    init(style: Style = .unselected) {
        self.style = style
        super.init(frame: .zero)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected.toggle()
    }
    
    private func configureViews() {
        profileImageView.image = image
        profileImageView.contentMode = .scaleAspectFit
        
        let width: CGFloat = 100
        circleBorderView.cornerRadius(width / 2)
        circleBorderView.border(width: 3.0, color: style.borderColor)
    }
    
    private func configureHierarchy() {
        addSubviews(circleBorderView)
        circleBorderView.addSubviews(profileImageView)
    }
    
    private func configureConstraints() {
        circleBorderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
