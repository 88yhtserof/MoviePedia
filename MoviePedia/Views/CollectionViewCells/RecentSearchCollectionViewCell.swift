//
//  RecentSearchCollectionViewCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/28/25.
//

import UIKit
import SnapKit

final class RecentSearchCollectionViewCell: UICollectionViewCell {
    
    private let outerView = UIView()
    private let titleLabel = UILabel()
    private let deleteButton = UIButton()
    private lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, deleteButton])
    
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
private extension RecentSearchCollectionViewCell {
    private func configureViews() {
        outerView.backgroundColor = .moviepedia_tagbackground
        outerView.cornerRadius(18)
        
        titleLabel.textColor = .moviepedia_background
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        
        let image = UIImage(systemName: "xmark")
        deleteButton.setImage(image, for: .normal)
        deleteButton.tintColor = .moviepedia_background
        
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.distribution = .fill
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(outerView)
        outerView.addSubviews(stackView)
    }
    
    private func configureConstraints() {
        outerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(12)
        }
    }
}
