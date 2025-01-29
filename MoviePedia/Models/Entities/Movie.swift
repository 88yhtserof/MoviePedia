//
//  Movie.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

struct Movie: Hashable, Codable {
    let id: Int
    let backdrop_path: String?
    let title: String
    let overview: String
    let poster_path: String
    let genre_ids: [Int]
    let release_date: String
    let vote_average: Double
}
