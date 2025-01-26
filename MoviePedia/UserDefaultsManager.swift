//
//  UserDefaultsManager.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

enum UserDefaultsManager {
    
    private enum Key: String {
        case user
        
        var defaultName: String {
            switch self {
            case .user: return "user"
            }
        }
    }
    
    static var user: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Key.user.defaultName),
                  let user = try? JSONDecoder().decode(User.self, from: data) else { return nil }
            return user
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: Key.user.defaultName)
            } catch {
                print("ERROR:", error)
            }
        }
    }
}
