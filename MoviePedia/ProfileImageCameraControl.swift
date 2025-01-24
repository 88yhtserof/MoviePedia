//
//  ProfileImageCameraControl.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

final class ProfileImageCameraControl: ProfileImageControl {
    
    private let circleView = UIView()
    private let cameraImageView = UIImageView()
    
    init() {
        super.init(style: .selected)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Push to profile image edit view controller")
    }
    
    private func configureViews() {
        let width: CGFloat = 30
        circleView.backgroundColor = .moviepedia_point
        circleView.cornerRadius(width / 2)
        
        cameraImageView.image = UIImage(systemName: "camera.fill")
        cameraImageView.tintColor = .moviepedia_foreground
    }
    
    private func configureHierarchy() {
        addSubviews(circleView)
        circleView.addSubviews(cameraImageView)
    }
    
    private func configureConstraints() {
        circleView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.bottom.trailing.equalToSuperview()
        }
        
        cameraImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(3)
        }
    }
}
