//
//  SearchRequest.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/30/25.
//

import Foundation
import Alamofire

struct SearchRequest {
    let query: String
    let includeAdult: Bool = false
    let language: String = "ko-KR"
    let page: Int
    
    var parameters: Parameters {
        return ["query": query, "include_adult": includeAdult, "language": language, "page": page]
    }
}
