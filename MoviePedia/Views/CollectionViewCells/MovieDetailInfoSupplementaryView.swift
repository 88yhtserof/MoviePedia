//
//  MovieDetailInfoSupplementaryView.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit
import SnapKit

final class MovieDetailInfoSupplementaryView: UICollectionReusableView {
    
    let pageControl = UIPageControl()
    private let releaseDateLabel = imageTitleLabel()
    private let ratingLabel = imageTitleLabel()
    private let genreLabel = imageTitleLabel()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with strings: [String]) {
        releaseDateLabel.title = strings[0]
        ratingLabel.title = strings[1]
        genreLabel.title = strings[2]
    }
}

//MARK: - Configuration
private extension MovieDetailInfoSupplementaryView {
    private func configureViews() {
        
        pageControl.backgroundColor = .moviepedia_background.withAlphaComponent(0.3)
        pageControl.cornerRadius(13)
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        
        releaseDateLabel.image = UIImage(systemName: "calendar")
        ratingLabel.image = UIImage(systemName: "star.fill")
        genreLabel.image = UIImage(systemName: "film.fill")
        let separatorLabel = UILabel()
        separatorLabel.text = "|"
        separatorLabel.textColor = .moviepedia_tagbackground
        
        [releaseDateLabel,  UILabel(), ratingLabel, UILabel(), genreLabel]
            .enumerated()
            .forEach{ (offset, view) in
                if offset % 2 != 0 {
                    (view as! UILabel).text = "|"
                    (view as! UILabel).textColor = .moviepedia_tagbackground
                }
                stackView.addArrangedSubview(view)
            }
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
    }
    
    private func configureHierarchy() {
        addSubviews(pageControl, stackView)
    }
    
    private func configureConstraints() {
        
        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-30)
            make.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
