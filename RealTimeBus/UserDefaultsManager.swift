//
//  UserDefaultsManager.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import Foundation
struct FavoriteBusStation: Codable {
    let busDetail: BusDetail
    let stationId: Int
    let dateAdded: Date
    let directions: String
}

struct DetailViewBus: Codable {
    let busDetail: BusDetail
    let stationId: Int
}

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let favoriteBusStationKey = "FavoriteBusStation"
    private let searchKey = "search"
    private let detailViewKey = "detailViewKey"

    private init() {}

    func saveFavorite(busDetail: BusDetail, stationId: Int,directions: String) {
        let favorite = FavoriteBusStation(busDetail: busDetail, stationId: stationId,dateAdded: Date(),directions: directions)

        // 将更新后的收藏列表编码并保存
        if let encodedFavorites = try? JSONEncoder().encode(favorite) {
            UserDefaults.standard.set(encodedFavorites, forKey: "\(favoriteBusStationKey)\(busDetail.id)")
        }
    }
    func savaSearchData(searchText: String, data: [BusDetail]) {
        // 将搜索数据保存
        if let encodedFavorites = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedFavorites, forKey: "\(searchKey)\(searchText)")
        }
    }
    
    func getSearchData(searchText: String) ->[BusDetail] {
        if let searchData = UserDefaults.standard.data(forKey: "\(searchKey)\(searchText)"),
            let busLines = try? JSONDecoder().decode([BusDetail].self, from: searchData){
            return busLines
        }
        return []
    }
    

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
        allFavorites.sort { $0.dateAdded > $1.dateAdded }
        return allFavorites
    }
    
    func getFavoriteBus() -> [BusDetail] {
        return getFavorites().map { $0.busDetail }
    }
    
    func getFavoriteDirec(for busId: Int) -> String {
        return getFavorites().first(where: { $0.busDetail.id == busId })?.directions ?? ""
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
        return favorites.contains(where: { $0.busDetail.id == busId })
    }
    
    // 用于获取关注的站点,不一定有关注,没关注,上层逻辑会处理
    func getFavoriteStationId(for busId: Int) -> FavoriteBusStation? {
        // 同样使用getFavorites()方法获取所有收藏项
        let favorites = getFavorites()

        // 尝试找到匹配的busId，如果找到，返回相应的stationId
        return favorites.first(where: { $0.busDetail.id == busId })
    }
    
    
    // 保存进入详情的数据
    func savaDetailViewData(busDetail: BusDetail, stationId: Int) {
        let detailData = DetailViewBus(busDetail: busDetail, stationId: stationId)
        // 将搜索数据保存
        if let encodedDetailViewData = try? JSONEncoder().encode(detailData) {
            UserDefaults.standard.set(encodedDetailViewData, forKey: detailViewKey)
        }
    }
    
    func getDetailViewData() ->DetailViewBus? {
        if let detailViewData = UserDefaults.standard.data(forKey: detailViewKey),
            let detail = try? JSONDecoder().decode(DetailViewBus.self, from: detailViewData){
            return detail
        }
        return nil
    }
    
    func removeDetailViewData() {
        UserDefaults.standard.removeObject(forKey: detailViewKey)
    }
}
