//
//  ImageCollectionCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit
import SnapKit

class ImageCollectionCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        addSubviews(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
