//
//  CircleFilledButton.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/9/25.
//

import UIKit

class CircleFilledButton: UIButton {
    
    private lazy var selectedConfiguration = configureSelectedConfiguration()
    private lazy var unselectedConfiguration = configureUnselectedConfiguration()
    
    var title: String? {
        didSet {
            selectedConfiguration.title = title
            unselectedConfiguration.title = title
            self.configuration = isSelected ? selectedConfiguration : unselectedConfiguration
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.configuration = isSelected ? selectedConfiguration : unselectedConfiguration
        }
    }
    
    init(isSelected: Bool = false) {
        super.init(frame: .zero)
        
        self.isSelected = isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width: CGFloat = self.frame.width
        self.cornerRadius(width / 2)
        self.border(width: isSelected ? 0 : 1, color: .moviepedia_tagbackground)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected.toggle()
    }
}

private extension CircleFilledButton {
    func configureSelectedConfiguration() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        
        config.baseBackgroundColor = .moviepedia_point
        config.baseForegroundColor = .moviepedia_foreground
        
        return config
    }
    
    func configureUnselectedConfiguration() -> UIButton.Configuration {
        var config = UIButton.Configuration.bordered()
        
        config.baseBackgroundColor = .moviepedia_background
        config.baseForegroundColor = .moviepedia_tagbackground
        
        return config
    }
}
