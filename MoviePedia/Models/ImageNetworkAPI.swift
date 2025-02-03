//
//  ImageNetworkAPI.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/1/25.
//

import Foundation

enum ImageNetworkAPI {
    case w500
    case original
    
    var query: String {
        switch self {
        case .w500:
            return "w500/"
        case .original:
            return "original/"
        }
    }
    
    var imageBaseURL: String {
        return "https://image.tmdb.org/t/p/"
    }
    
    var endPoint: String {
        return imageBaseURL + self.query
    }
}
