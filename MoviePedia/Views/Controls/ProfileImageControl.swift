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
        
        var alpha: CGFloat {
            switch self {
            case .selected:
                return 1
            case .unselected:
                return 0.5
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
            style = isSelected ? .selected : .unselected
        }
    }
    
    private var style: Style {
        didSet {
            circleBorderView.alpha = style.alpha
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width: CGFloat = frame.width
        circleBorderView.cornerRadius(width / 2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected.toggle()
    }
}

//MARK: - Configuration
private extension ProfileImageControl {
    func configureViews() {
        profileImageView.image = image
        profileImageView.contentMode = .scaleAspectFit
        
        circleBorderView.alpha = style.alpha
        circleBorderView.border(width: 3.0, color: style.borderColor)
        circleBorderView.backgroundColor = .moviepedia_background
    }
    
    func configureHierarchy() {
        addSubviews(circleBorderView)
        circleBorderView.addSubviews(profileImageView)
    }
    
    func configureConstraints() {
        circleBorderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
