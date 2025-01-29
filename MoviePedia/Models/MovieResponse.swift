//
//  MovieResponse.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

struct MovieResponse: Decodable {
    var page: Int
    var results: [Movie]
}


