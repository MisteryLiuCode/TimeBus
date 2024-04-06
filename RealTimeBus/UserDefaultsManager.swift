//
//  UserDefaultsManager.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import Foundation
struct FavoriteBusStation: Codable {
    let busId: Int
    let stationId: Int
}

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let favoriteBusStationKey = "FavoriteBusStation"

    private init() {}

    func saveFavorite(busId: Int, stationId: Int) {
        let favorite = FavoriteBusStation(busId: busId, stationId: stationId)
//        var favorites = getFavorites() // 获取当前所有收藏
//        favorites.append(favorite) // 添加新的收藏
        
        // 将更新后的收藏列表编码并保存
        if let encodedFavorites = try? JSONEncoder().encode(favorite) {
            UserDefaults.standard.set(encodedFavorites, forKey: "\(favoriteBusStationKey)\(busId)")
        }
    }

//    func getFavorites() -> [FavoriteBusStation] {
//        guard let savedData = UserDefaults.standard.data(forKey: favoriteBusStationKey),
//              let savedFavorites = try? JSONDecoder().decode([FavoriteBusStation].self, from: savedData) else {
//            return []
//        }
//
//        return savedFavorites
//    }
    func getFavorites() -> [FavoriteBusStation] {
        var allFavorites = [FavoriteBusStation]()

        // 获取UserDefaults中所有的键
        let userDefaultsKeys = UserDefaults.standard.dictionaryRepresentation().keys
        
        // 过滤出以favoriteBusStationKey为开头的键
        let filteredKeys = userDefaultsKeys.filter { $0.hasPrefix(favoriteBusStationKey) }
        
        // 遍历过滤后的键，尝试获取数据并解码
        for key in filteredKeys {
            if let savedData = UserDefaults.standard.data(forKey: key),
               let savedFavorites = try? JSONDecoder().decode(FavoriteBusStation.self, from: savedData) {
                // 将解码后的收藏站点添加到总数组中
                allFavorites.append(savedFavorites)
            }
        }
        
        return allFavorites
    }

    
    
    

    func getFavoriteBusIds() -> [Int] {
        return getFavorites().map { $0.busId }
    }

    // Remove favorite
    func removeFavorite(busId: Int) {
        UserDefaults.standard.removeObject(forKey: "\(favoriteBusStationKey)\(busId)")
    }

    // Check if a specific bus is favorite
    func isFavorite(busId: Int) -> Bool {
        // 直接使用之前定义好的getFavorites()方法获取所有收藏项目
        let favorites = getFavorites()

        // 检查是否有匹配的busId，如果有，则此公交是收藏的
        return favorites.contains(where: { $0.busId == busId })
    }

    // Get stored favorite stationId for a bus, if exists
    func getFavoriteStationId(for busId: Int) -> Int? {
        // 同样使用getFavorites()方法获取所有收藏项
        let favorites = getFavorites()

        // 尝试找到匹配的busId，如果找到，返回相应的stationId
        return favorites.first(where: { $0.busId == busId })?.stationId
    }
}
