//
//  Movie.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

struct Movie: Hashable, Codable {
    let id: Int
    let backdrop_path: String?
    let title: String
    let overview: String
    let poster_path: String?
    let genre_ids: [Int]
    let release_date: String
    let vote_average: Double?
}

enum Genre: Int {
    case action = 28
    case animation = 16
    case crime = 80
    case drama = 18
    case fantasy = 14
    case horror = 27
    case mistery = 9648
    case sf = 878
    case thriller = 53
    case western = 37
    case adventure = 12
    case comedy = 35
    case documentry = 99
    case family = 10751
    case history = 36
    case music = 10402
    case romance = 10749
    case tv_movie = 10770
    case war = 10405
    
    var name_kr: String {
        switch self {
        case .action:
            return "액션"
        case .animation:
            return "애니메이션"
        case .crime:
            return "범죄"
        case .drama:
            return "드라마"
        case .fantasy:
            return "판타지"
        case .horror:
            return "공포"
        case .mistery:
            return "미스터리"
        case .sf:
            return "SF"
        case .thriller:
            return "스릴러"
        case .western:
            return "서부"
        case .adventure:
            return "모험"
        case .comedy:
            return "코미디"
        case .documentry:
            return "다큐멘터리"
        case .family:
            return "가족"
        case .history:
            return "역사"
        case .music:
            return "음악"
        case .romance:
            return "로맨스"
        case .tv_movie:
            return "TV 영화"
        case .war:
            return "전쟁"
        }
    }
}
