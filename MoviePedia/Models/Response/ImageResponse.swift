//
//  ImageResponse.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/1/25.
//

import Foundation

struct ImageResponse: Codable {
    let id: Int
    let backdrops: [Image]?
    let posters: [Image]?
}
