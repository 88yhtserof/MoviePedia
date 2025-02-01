//
//  TextCollectionViewCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit
import SnapKit

final class TextCollectionViewCell: UICollectionViewCell {
    
    private let textLabel = UILabel()
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var numberOfLines: Int = 0 {
        didSet {
            textLabel.numberOfLines = numberOfLines
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.numberOfLines = numberOfLines
        textLabel.font = .systemFont(ofSize: 14, weight: .regular)
        textLabel.textColor = .moviepedia_foreground
        
        addSubviews(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
