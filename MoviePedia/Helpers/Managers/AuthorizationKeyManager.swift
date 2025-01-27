//
//  AuthorizationKeyManager.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

enum AuthorizationKeyManager {
    case tmdb
    
    var apiKey: String? {
        return Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String
    }
}
