//
//  TitleSupplementaryView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/28/25.
//

import UIKit
import SnapKit

final class TitleSupplementaryView: UICollectionReusableView {
    
    private let titleLabel = UILabel()
    private let rightAccessoryStackView = UIStackView()
    
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
    
    func addRightAccessoryView(_ view: UIView) {
        rightAccessoryStackView.addArrangedSubview(view)
    }
}

//MARK: - Configuration
private extension TitleSupplementaryView {
    private func configureViews() {
        titleLabel.textColor = .moviepedia_tagbackground
        titleLabel.font = .systemFont(ofSize: 16, weight: .heavy)
        
        rightAccessoryStackView.axis = .horizontal
        rightAccessoryStackView.distribution = .fill
        rightAccessoryStackView.alignment = .center
    }
    
    private func configureHierarchy() {
        addSubviews(titleLabel, rightAccessoryStackView)
    }
    
    private func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rightAccessoryStackView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
        }
    }
}
