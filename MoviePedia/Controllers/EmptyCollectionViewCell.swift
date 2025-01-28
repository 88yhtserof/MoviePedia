//
//  EmptyCollectionViewCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/28/25.
//

import UIKit
import SnapKit

final class EmptyCollectionViewCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with string: String) {
        titleLabel.text = string
    }
}

//MARK: - Configuration
private extension EmptyCollectionViewCell {
    private func configureViews() {
        titleLabel.textColor = .moviepedia_tagbackground
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
    }
    
    private func configureHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    private func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
