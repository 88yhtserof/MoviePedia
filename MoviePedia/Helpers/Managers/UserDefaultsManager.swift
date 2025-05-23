//
//  UserDefaultsManager.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

@propertyWrapper
struct MoviePediaUserDefaults<T: Codable> {
    
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let user = try? JSONDecoder().decode(T.self, from: data) else {
                print("Failed to load user from UserDefaults")
                return defaultValue
            }
            return user
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: key)
            } catch {
                print("ERROR: Failed to save user to UserDefaults", error, terminator: "\n")
            }
        }
    }
    
}

enum UserDefaultsManager {
    
    private enum Key: String, CaseIterable {
        case user
        case isOnboardingNotNeeded
        case likedMovies
        case recentSearches
    }
    
    static func reset() {
        Key.allCases
            .forEach {
                UserDefaults.standard.removeObject(forKey: $0.rawValue)
            }
    }
    
    @MoviePediaUserDefaults<User?>(key: Key.user.rawValue, defaultValue: nil)
    static var user
    
    @MoviePediaUserDefaults<Bool>(key: Key.isOnboardingNotNeeded.rawValue, defaultValue: false)
    static var isOnboardingNotNeeded
    
    @MoviePediaUserDefaults<[Movie]>(key: Key.likedMovies.rawValue, defaultValue: [])
    static var likedMovies
    
    @MoviePediaUserDefaults<Set<RecentSearch>>(key: Key.recentSearches.rawValue, defaultValue: [])
    static var recentSearches
}
