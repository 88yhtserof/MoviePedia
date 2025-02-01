//
//  CreditRequest.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/1/25.
//

import Foundation
import Alamofire

struct CreditRequest {
    let movieID: Int
    let language: String = "ko-KR"
    
    var parameters: Parameters {
        return ["language": language]
    }
}
