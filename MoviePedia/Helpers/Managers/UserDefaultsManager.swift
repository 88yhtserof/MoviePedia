//
//  UserDefaultsManager.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation

enum UserDefaultsManager {
    
    private enum Key: String, CaseIterable {
        case user
        case isOnboardingNotNeeded
        case likedMovies
        case recentSearches
        
        var defaultName: String {
            return rawValue
        }
    }
    
    static func reset() {
        Key.allCases
            .forEach {
                UserDefaults.standard.removeObject(forKey: $0.defaultName)
            }
    }
    
    // TODO: - 추상화
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
    
    static var isOnboardingNotNeeded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Key.isOnboardingNotNeeded.defaultName)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.isOnboardingNotNeeded.defaultName)
        }
    }
    
    static var likedMovies: [Movie] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Key.likedMovies.defaultName),
                  let decoded = try? JSONDecoder().decode([Movie].self, from: data) else { return [] }
            return decoded
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: Key.likedMovies.defaultName)
            } catch {
                print("ERROR:", error)
            }
        }
    }
    
    static var recentSearches: Set<RecentSearch> {
        get {
            guard let data = UserDefaults.standard.data(forKey: Key.recentSearches.defaultName),
                  let decoded = try? JSONDecoder().decode(Set<RecentSearch>.self, from: data) else { return Set<RecentSearch>() }
            return decoded
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: Key.recentSearches.defaultName)
            } catch {
                print("ERROR:", error)
            }
        }
    }
}
