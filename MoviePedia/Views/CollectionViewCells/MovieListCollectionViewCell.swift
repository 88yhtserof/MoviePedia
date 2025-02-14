//
//  MovieListCollectionViewCell.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/30/25.
//

import UIKit
import SnapKit
import Kingfisher

final class MovieListCollectionViewCell: UICollectionViewCell {
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private lazy var titleInfoStackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
    private let firGenreLabel = RoundLabel()
    private let secGenreLabel = RoundLabel()
    private let anotherGenreLabel = UILabel()
    private lazy var genreStackView = UIStackView(arrangedSubviews: [firGenreLabel, secGenreLabel])
    let likeButton = LikeSelectedButton()
    private let separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
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
        
        if let title = movieInfo.movie.title {
            titleLabel.text = title
        }
        
        if let release_date = movieInfo.movie.release_date {
            dateLabel.text = DateFormatterManager.shared.string(from: release_date, from: .originalMovieReleaseDate, to: .movieReleaseDate)
        }
        
        if let genre_ids = movieInfo.movie.genre_ids {
            genre_ids
                .prefix(2)
                .compactMap{ Genre(rawValue: $0) }
                .enumerated()
                .forEach { (i, genre) in
                    (genreStackView.arrangedSubviews[i] as! RoundLabel).text = genre.name_kr
                }
        }
        
        if let path = movieInfo.movie.poster_path,
           let imageURL = URL(string: ImageNetworkAPI.w500.endPoint + path) {
            posterImageView.kf.indicatorType = .activity
            posterImageView.kf.setImage(with: imageURL, options: [.transition(.fade(1.2))])
        }
        
        likeButton.isSelected = movieInfo.isLiked
        likeButton.tag = movieInfo.movie.id
    }
    
}

//MARK: - Configuration
private extension MovieListCollectionViewCell {
    private func configureViews() {
        posterImageView.backgroundColor = .moviepedia_subbackground
        posterImageView.cornerRadius()
        posterImageView.tintColor = .moviepedia_tagbackground
        
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .moviepedia_foreground
        titleLabel.font = . systemFont(ofSize: 16, weight: .bold)
        
        dateLabel.textColor = .moviepedia_subbackground
        dateLabel.font = .systemFont(ofSize: 14, weight: .light)
        
        titleInfoStackView.axis = .vertical
        titleInfoStackView.spacing = 3
        titleInfoStackView.distribution = .fill
        titleInfoStackView.alignment = .leading
        
        [firGenreLabel, secGenreLabel]
            .forEach{ (label: RoundLabel) in
                label.textColor = .moviepedia_foreground
                label.backgroundColor = UIColor.moviepedia_subbackground
                label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            }
        
        genreStackView.axis = .horizontal
        genreStackView.distribution = .equalSpacing
        genreStackView.spacing = 4
        
        separatorView.backgroundColor = .darkGray
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(posterImageView, titleInfoStackView, genreStackView, likeButton, separatorView)
    }
    
    private func configureConstraints() {
        let verticalInset: CGFloat = 14
        let horizontalInset: CGFloat = 12
        
        posterImageView.snp.makeConstraints { make in
            make.width.equalTo(posterImageView.snp.height).multipliedBy(0.75)
            make.top.equalToSuperview().inset(verticalInset)
            make.leading.equalToSuperview().inset(horizontalInset)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        titleInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(posterImageView).inset(4)
            make.leading.equalTo(posterImageView.snp.trailing).offset(14)
            make.trailing.equalToSuperview().inset(horizontalInset)
        }
        
        genreStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(titleInfoStackView.snp.bottom)
            make.leading.equalTo(titleInfoStackView)
            make.trailing.lessThanOrEqualTo(likeButton.snp.leading).offset(-8)
            make.bottom.equalTo(posterImageView)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.trailing.equalTo(titleInfoStackView.snp.trailing)
            make.centerY.equalTo(genreStackView)
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.8)
            make.top.equalTo(posterImageView.snp.bottom).offset(verticalInset)
            make.bottom.equalToSuperview().inset(verticalInset)
            make.horizontalEdges.equalToSuperview().inset(horizontalInset)
        }
    }
}
