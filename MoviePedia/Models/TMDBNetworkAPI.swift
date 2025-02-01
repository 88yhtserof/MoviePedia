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
    case search(SearchRequest)
    case image(ImageRequest)
    
    static let authorizationKey = AuthorizationKeyManager.tmdb.apiKey ?? ""
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    var baseURL: String {
        return "https://api.themoviedb.org/3/"
    }
    
    var endPoint: URL? {
        var path: String
        switch self {
        case .treding(let request):
            path = "trending/movie/\(request.time_window)"
        case .search:
            path = "search/movie"
        case .image(let request):
            path = "movie/\(request.movieID)/images"
        }
        return URL(string: baseURL + path)
    }
    
    var headers: HTTPHeaders {
        return ["Authorization": "Bearer \(TMDBNetworkAPI.authorizationKey)"]
    }
    
    var method: HTTPMethod {
        switch self {
        case .treding, .search, .image:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .treding(let request):
            return request.parameters
        case .search(let request):
            return request.parameters
        case .image:
            return [:]
        }
    }
}
