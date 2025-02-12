//
//  TMDBNetworkError.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/1/25.
//

import Foundation

enum TMDBNetworkError: String, LocalizedError {
    case badRequest
    case unauthorized
    case notExistServer
    case tryAgainLater
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "잘못된 요청입니다.\n입력값을 확인해주세요."
        case .unauthorized:
            return "권한이 없습니다."
        case .notExistServer:
            return "존재하지 않는 서버입니다."
        case .tryAgainLater:
            return "잠시 서버에 오류가 발생했습니다.\n나중에 다시 시도하십시오."
        case .unknown:
            return "알 수 없는 오류입니다.\n관리자에게 문의하세요."
        }
    }
}
