//
//  ToggleSelectionControl.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/9/25.
//

import UIKit
import SnapKit

class ToggleSelectionControl: UIControl {
    
    let firstButton = CircleFilledButton()
    let secondButton = CircleFilledButton()
    private lazy var stackView = UIStackView(arrangedSubviews: [firstButton, secondButton])
    
    var selectedValue: String?
    
    init() {
        super.init(frame: .zero)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if !sender.isSelected {
            selectedValue = nil
        } else {
            if sender == firstButton {
                secondButton.isSelected = false
                selectedValue = firstButton.title
            } else {
                firstButton.isSelected = false
                selectedValue = secondButton.title
            }
        }
        sendActions(for: .valueChanged)
    }
}

private extension ToggleSelectionControl {
    func configureViews() {
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        firstButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        secondButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func configureHierarchy() {
        addSubviews(stackView)
    }
    
    func configureConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.snp.width).multipliedBy(2).offset(8)
        }
    }
}
