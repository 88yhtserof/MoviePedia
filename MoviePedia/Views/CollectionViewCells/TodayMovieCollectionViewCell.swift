//
//  TodayMovieCollectionViewCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/29/25.
//

import UIKit
import SnapKit
import Kingfisher

final class TodayMovieCollectionViewCell: UICollectionViewCell {
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    let likeButton = LikeSelectedButton()
    private lazy var titleStackView = UIStackView(arrangedSubviews: [titleLabel, likeButton])
    private let contentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = UIImage(systemName: "photo")
        likeButton.tag = 0
    }
    
    func configure(with movieInfo: MovieInfo) {
        titleLabel.text = movieInfo.movie.title
        contentLabel.text = movieInfo.movie.overview
        likeButton.isSelected = movieInfo.isLiked
        likeButton.tag = movieInfo.movie.id
        
        if let path = movieInfo.movie.poster_path,
           let imageURL = URL(string: ImageNetworkAPI.original.endPoint + path) {
            posterImageView.kf.indicatorType = .activity
            posterImageView.kf.setImage(with: imageURL, options: [.transition(.fade(1.2))])
        }
    }
}

//MARK: - Configuration
private extension TodayMovieCollectionViewCell {
    private func configureViews() {
        posterImageView.backgroundColor = .moviepedia_subbackground
        posterImageView.tintColor = .moviepedia_tagbackground
        posterImageView.cornerRadius()
        posterImageView.contentMode = .scaleAspectFill
        
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .moviepedia_tagbackground
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        
        contentLabel.numberOfLines = 2
        contentLabel.textColor = .moviepedia_foreground
        contentLabel.font = .systemFont(ofSize: 14)
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(posterImageView, titleStackView, contentLabel)
    }
    
    private func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(43)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(titleLabel.snp.height)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom)
            make.horizontalEdges.equalTo(titleStackView)
            make.bottom.equalToSuperview()
        }
    }
}
