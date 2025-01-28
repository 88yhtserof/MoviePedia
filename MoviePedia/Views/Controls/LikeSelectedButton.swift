//
//  LikeSelectedButton.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/29/25.
//

import UIKit

class LikeSelectedButton: UIButton {
    
    private lazy var likedConfiguration = buttonConfiguration(for: .liked)
    private lazy var unlikedConfiguration = buttonConfiguration(for: .unliked)
    
    override var isSelected: Bool {
        didSet {
            configuration = isSelected ? likedConfiguration : unlikedConfiguration
        }
    }
    
    enum Status: String {
        case liked = "heart.fill"
        case unliked = "heart"
        
        var imageName: String {
            return rawValue
        }
    }
    
    init() {
        super.init(frame: .zero)
        isSelected = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected.toggle()
    }
    
    private func buttonConfiguration(for status: Status) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: status.imageName)
        configuration.baseForegroundColor = .moviepedia_point
        configuration.baseBackgroundColor = .clear
        return configuration
    }
}
