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
        
        var formatter: DateFormatter {
            switch self {
            case .userCreatedAt:
                return shared.userCreatedAt
            }
        }
    }
    
    lazy var userCreatedAt: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        return dateFormatter
    }()
    
    func string(from date: Date, format: Format) -> String {
        return format.formatter.string(from: date)
    }
}
