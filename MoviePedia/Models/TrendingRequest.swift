//
//  TrendingRequest.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation
import Alamofire

struct TrendingRequest {
    let language: String = "ko-KR"
    let page: Int = 1
    let time_window: Time = .day
    
    enum Time: String {
        case day, week
    }
    
    var parameters: Parameters {
        return ["language": language, "page": page]
    }
}
