//
//  TMDBNetworkAPI.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation
import Alamofire

enum TMDBNetworkAPI {
    case treding(TrendingRequest)
    
    static let authorizationKey = AuthorizationKeyManager.tmdb.apiKey ?? ""
    
    var baseURL: String {
        return "https://api.themoviedb.org/3/"
    }
    
    var endPoint: URL? {
        var path: String
        switch self {
        case .treding(let request):
            path = "trending/movie/\(request.time_window)"
        }
        return URL(string: baseURL + path)
    }
    
    var headers: HTTPHeaders {
        return ["Authorization": "Bearer \(TMDBNetworkAPI.authorizationKey)"]
    }
    
    var method: HTTPMethod {
        switch self {
        case .treding:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .treding(let request):
            return request.parameters
        }
    }
}
