//
//  DateFormatterManager.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/29/25.
//

import Foundation

final class DateFormatterManager {
    static let shared = DateFormatterManager()
    
    private init(){}
    
    enum Format {
        case userCreatedAt
        case movieReleaseDate
        case originalMovieReleaseDate
        
        var formatter: DateFormatter {
            switch self {
            case .userCreatedAt:
                return shared.userCreatedAt
            case .movieReleaseDate:
                return shared.movieReleaseDate
            case .originalMovieReleaseDate:
                return shared.originalMovieReleaseDate
            }
        }
    }
    
    lazy var userCreatedAt: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        return dateFormatter
    }()
    
    lazy var movieReleaseDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter
    }()
    
    lazy var originalMovieReleaseDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    func string(from date: Date, format: Format) -> String {
        return format.formatter.string(from: date)
    }
    
    func date(from string: String, format: Format) -> Date? {
        return format.formatter.date(from: string)
    }
    
    func string(from string: String, from beforeFormat: Format, to afterFormat: Format) -> String? {
        guard let date = beforeFormat.formatter.date(from: string) else { return nil }
        return afterFormat.formatter.string(from: date)
    }
}
