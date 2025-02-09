//
//  ProfileMBTIOptionView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/9/25.
//

import UIKit
import SnapKit

class ProfileMBTIOptionView: UIView {
    
    let firstToggleControl = ToggleSelectionControl()
    let secondToggleControl = ToggleSelectionControl()
    let thirdToggleControl = ToggleSelectionControl()
    let fourthToggleControl = ToggleSelectionControl()
    lazy var stackView = UIStackView(arrangedSubviews: [firstToggleControl, secondToggleControl, thirdToggleControl, fourthToggleControl])
    
    init() {
        super.init(frame: .zero)
        
        configureViews()
        configureHierarachy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ProfileMBTIOptionView {
    func configureViews() {
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        firstToggleControl.firstButton.title = "E"
        firstToggleControl.secondButton.title = "I"
        firstToggleControl.tag = 0
        
        secondToggleControl.firstButton.title = "S"
        secondToggleControl.secondButton.title = "N"
        secondToggleControl.tag = 1
        
        thirdToggleControl.firstButton.title = "T"
        thirdToggleControl.secondButton.title = "F"
        thirdToggleControl.tag = 2
        
        fourthToggleControl.firstButton.title = "J"
        fourthToggleControl.secondButton.title = "P"
        fourthToggleControl.tag = 3
    }
    
    func configureHierarachy() {
        addSubviews(stackView)
    }
    
    func configureConstraints() {
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
    }
}
