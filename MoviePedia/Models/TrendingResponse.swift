//
//  TrendingResponse.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

struct TrendingResponse: Decodable {
    var page: Int
    var results: [Trending]
}

struct Trending: Decodable {
    let id: Int
    let backdrop_path: String
    let title: String
    let overview: String
    let poster_path: String
    let genre_ids: [Int]
    let release_date: String
    let vote_average: Double
}
