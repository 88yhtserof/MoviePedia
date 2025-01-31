//
//  RecentSearch.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/30/25.
//

import Foundation

struct RecentSearch: Hashable, Equatable, Codable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.search == rhs.search
    }
    
    var search: String
    var date: Date
}
