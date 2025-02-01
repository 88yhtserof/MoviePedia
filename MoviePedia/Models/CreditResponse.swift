//
//  CreditResponse.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/31/25.
//

import Foundation

struct CreditResponse: Codable {
    let id: Int
    let cast: [Credit]?
}
