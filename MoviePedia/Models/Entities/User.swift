//
//  User.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

struct User: Identifiable, Codable {
    var id = UUID()
    let createdAt: Date
    var nickname: String
    var profileImage: String
}
