//
//  LikeSelectedButton.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/29/25.
//

import UIKit

class LikeSelectedButton: UIButton {
    
    private lazy var likedConfiguration = likedButtonConfiguration()
    private lazy var unlikedConfiguration = unlikedButtonConfiguration()
    
    override var isSelected: Bool {
        didSet {
            configuration = isSelected ? likedConfiguration : unlikedConfiguration
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
    
    private func likedButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "heart.fill")
        configuration.image?.withTintColor(.moviepedia_point)
        return configuration
    }
    
    private func unlikedButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "heart")
        configuration.image?.withTintColor(.moviepedia_point)
        return configuration
    }
}
