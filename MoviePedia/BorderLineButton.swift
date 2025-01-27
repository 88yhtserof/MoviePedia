//
//  BorderLineButton.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit
import SnapKit

class BorderLineButton: UIButton {
    
    private let title: String
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            alpha = isUserInteractionEnabled ? 1 : 0.5
        }
    }
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configureViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseBackgroundColor = .moviepedia_background
        config.baseForegroundColor = .moviepedia_point
        configuration = config
        
        cornerRadius(18)
        border(color: .moviepedia_point)
        
        self.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
}
