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
    let titleButton = UIButton()
    private let deleteButton = UIButton()
    private lazy var stackView = UIStackView(arrangedSubviews: [titleButton, deleteButton])
    
    var deleteAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteButtonTapped() {
        deleteAction?()
    }
    
    func configure(with string: String) {
        let attiributedTitle = NSAttributedString(string: string, attributes: [ .font : UIFont.systemFont(ofSize: 14) ])
        titleButton.setAttributedTitle(attiributedTitle, for: .normal)
    }
}

//MARK: - Configuration
private extension RecentSearchCollectionViewCell {
    private func configureViews() {
        outerView.backgroundColor = .moviepedia_tagbackground
        outerView.cornerRadius(15)
        
        titleButton.setTitleColor(.moviepedia_background, for: .normal)
        
        let image = UIImage(systemName: "xmark")
        deleteButton.setImage(image, for: .normal)
        deleteButton.tintColor = .moviepedia_background
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
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
