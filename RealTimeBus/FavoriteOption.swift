//
//  FavoriteOption.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/4/21.
//

import Foundation
enum FavoriteOption: String, CaseIterable {
    case commuteToWork = "上班方向"
    case commuteHome = "下班方向"
    case justFavorite = "仅收藏"
    
    var displayName: String {
        switch self {
        case .commuteToWork:
            return "上班方向"
        case .commuteHome:
            return "下班方向"
        case .justFavorite:
            return "仅收藏"
        }
    }
}
