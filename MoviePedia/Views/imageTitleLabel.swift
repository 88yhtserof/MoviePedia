//
//  imageTitleLabel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit
import SnapKit

class imageTitleLabel: UIView {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private lazy var stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        imageView.tintColor = .moviepedia_tagbackground
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .light)
        titleLabel.textColor = .moviepedia_tagbackground
        
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        
        addSubviews(stackView)
        
        imageView.snp.makeConstraints { make in
            make.size.width.equalTo(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
