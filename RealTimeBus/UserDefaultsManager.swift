//
//  UserDefaultsManager.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import Foundation
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let favoritesKey = "favorites"

    private init() {}

    func saveFavorite(busId: Int) {
        var favorites = getFavorites()
        if !favorites.contains(busId) {
            favorites.append(busId)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
        }
    }

    func removeFavorite(busId: Int) {
        var favorites = getFavorites()
        if let index = favorites.firstIndex(of: busId) {
            favorites.remove(at: index)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
        }
    }

    func getFavorites() -> [Int] {
        return UserDefaults.standard.array(forKey: favoritesKey) as? [Int] ?? []
    }

    func isFavorite(busId: Int) -> Bool {
        return getFavorites().contains(busId)
    }
}
