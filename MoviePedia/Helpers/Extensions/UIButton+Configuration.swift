//
//  UIButton+Configuration.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import UIKit

extension UIButton.Configuration {
    static func headerAccessoryButton(_ title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .moviepedia_point
        config.baseBackgroundColor = .clear
        return config
    }
}
