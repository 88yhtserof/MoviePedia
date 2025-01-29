//
//  ProfileImageCollectionViewCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/25/25.
//

import UIKit
import SnapKit

final class ProfileImageCollectionViewCell: UICollectionViewCell {
    
    private let profileImageControl = ProfileImageControl(style: .unselected)
    
    override var isSelected: Bool {
        didSet {
            profileImageControl.isSelected.toggle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureView()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configue(with imageName: String) {
        let image = UIImage(named: imageName)
        profileImageControl.image = image
    }
}

//MARK: - Configuration
private extension ProfileImageCollectionViewCell {
    func configureView() {
        profileImageControl.image = UIImage(systemName: "person.circle.fill")
        profileImageControl.isEnabled = false
    }
    
    func configureHierarchy() {
        contentView.addSubviews(profileImageControl)
    }
    
    func configureConstraints() {
        profileImageControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
