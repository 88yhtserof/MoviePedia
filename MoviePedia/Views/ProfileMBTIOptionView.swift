//
//  ProfileMBTIOptionView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/9/25.
//

import UIKit
import SnapKit

class ProfileMBTIOptionView: UIView {
    
    private let firstToggleControl = ToggleSelectionControl()
    private let secondToggleControl = ToggleSelectionControl()
    private let thirdToggleControl = ToggleSelectionControl()
    private let fourthToggleControl = ToggleSelectionControl()
    private lazy var stackView = UIStackView(arrangedSubviews: [firstToggleControl, secondToggleControl, thirdToggleControl, fourthToggleControl])
    
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
        
        secondToggleControl.firstButton.title = "S"
        secondToggleControl.secondButton.title = "N"
        
        thirdToggleControl.firstButton.title = "T"
        thirdToggleControl.secondButton.title = "F"
        
        fourthToggleControl.firstButton.title = "J"
        fourthToggleControl.secondButton.title = "P"
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
