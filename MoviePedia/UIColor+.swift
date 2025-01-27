//
//  UIColor+.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit

extension UIColor {
    
    static let moviepedia_point = UIColor(named: MoviePediaColor.blue.title) ?? .black
    static let moviepedia_foreground = UIColor(named: MoviePediaColor.white.title) ?? .black
    static let moviepedia_tagbackground = UIColor(named: MoviePediaColor.lightGray.title) ?? .black
    static let moviepedia_subbackground = UIColor(named: MoviePediaColor.darkGray.title) ?? .black
    static let moviepedia_background = UIColor(named: MoviePediaColor.black.title) ?? .black
    
    enum MoviePediaColor: String {
        case blue = "moviepedia_blue"
        case white = "moviepedia_white"
        case lightGray = "moviepedia_lightGray"
        case darkGray = "moviepedia_darkGray"
        case black = "moviepedia_black"
        
        var title: String {
            return rawValue
        }
    }
    
}
