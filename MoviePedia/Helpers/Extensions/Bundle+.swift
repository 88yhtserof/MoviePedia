//
//  Bundle+.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

extension Bundle {
    var tmdbApiKey: String? {
        return infoDictionary?["TMDB_API_KEY"] as? String
    }
}
