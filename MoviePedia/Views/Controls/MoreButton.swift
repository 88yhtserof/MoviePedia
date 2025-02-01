//
//  MoreButton.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit

final class MoreButton: UIButton {
    
    let unselectedConfiguration = UIButton.Configuration.headerAccessoryButton("More")
    let selectedConfiguration = UIButton.Configuration.headerAccessoryButton("Hide")
    
    override var isSelected: Bool {
        didSet {
            configuration = isSelected ? selectedConfiguration : unselectedConfiguration
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected.toggle()
    }
    
    init() {
        super.init(frame: .zero)
        isSelected = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
