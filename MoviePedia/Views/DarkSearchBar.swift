//
//  DarkSearchBar.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/29/25.
//

import UIKit

class DarkSearchBar: UISearchBar {
    
    init() {
        super.init(frame: .zero)
        
        configureSearchBar()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSearchBar() {
        backgroundImage = UIImage()
        searchTextField.backgroundColor = .white.withAlphaComponent(0.1)
        searchTextField.tintColor = .moviepedia_foreground
        searchTextField.textColor = .moviepedia_foreground
        searchTextField.leftView?.tintColor = .moviepedia_foreground
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGray2]
        searchTextField.attributedPlaceholder = NSAttributedString(string: "영화 제목을 검색하세요", attributes: attributes)
    }
}
