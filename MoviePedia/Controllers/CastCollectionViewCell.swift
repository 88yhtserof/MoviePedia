//
//  CastCollectionViewCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit
import SnapKit
import Kingfisher

final class CastCollectionViewCell: UICollectionViewCell {
    
    private let castImageView = UIImageView()
    private let nameLabel = UILabel()
    private let characterLabel = UILabel()
    private lazy var labelStackView = UIStackView(arrangedSubviews: [nameLabel, characterLabel])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        castImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .moviepedia_foreground
        characterLabel.font = .systemFont(ofSize: 14, weight: .light)
        characterLabel.textColor = .moviepedia_foreground
        
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.distribution = .equalSpacing
        
        contentView.addSubviews(castImageView, labelStackView)
        
        castImageView.snp.makeConstraints { make in
            make.width.equalTo(snp.height)
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(labelStackView.snp.leading).offset(-8)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.centerY.equalTo(castImageView)
            make.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        castImageView.cornerRadius(frame.height / 2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        castImageView.image = UIImage(systemName: "photo")
    }
    
    func configure(with cast: Cast) {
        if let path = cast.profile_path,
           let imageURL = URL(string: TMDBNetworkAPI.imageBaseURL + path) {
            castImageView.kf.setImage(with: imageURL)
        }
        
        nameLabel.text = cast.name
        characterLabel.text = cast.character
    }
}
