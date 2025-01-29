//
//  RoundLabel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/30/25.
//

import UIKit
import SnapKit

class RoundLabel: UIView {
    
    private let label = UILabel()
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    var font: UIFont?{
        didSet {
            label.font = font
        }
    }
    
    var textColor: UIColor = .moviepedia_foreground {
        didSet {
            label.textColor = textColor
        }
    }
     
    init() {
        super.init(frame: .zero)
        
        cornerRadius(5)
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
