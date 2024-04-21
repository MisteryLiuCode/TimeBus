//
//  LiveActivity.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/4/21.
//

import Foundation
import ActivityKit


/// 开启灵动岛显示功能
func startActivity(busDetail: BusDetail, favoriteStationId: Int,arriveTime: Int) {
    Task {
        let favoriteStationName: String? = UserDefaultsManager.shared.getFavoriteStationId(for: busDetail.id)?.busDetail.stations.first(where: { $0.id == favoriteStationId })?.stopName
        let attributes = RealTimeBusWeightAttributes(lineName: busDetail.lineName, stationName: favoriteStationName ?? "未知站")
        let initialContentState = RealTimeBusWeightAttributes.ContentState(estimatedArrival: arriveTime)
        do {
            let myActivity = try Activity<RealTimeBusWeightAttributes>.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil)
            print("Requested a Live Activity \(myActivity.id)")
            print("已开启灵动岛显示 App切换到后台即可看到")
        } catch (let error) {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
        }
    }
}


/// 更新灵动岛显示
func updateActivity(arriveTime: Int){
    Task{
        let updatedStatus = RealTimeBusWeightAttributes.ContentState(estimatedArrival: arriveTime)
        for activity in Activity<RealTimeBusWeightAttributes>.activities{
            await activity.update(using: updatedStatus)
            print("已更新灵动岛显示 arriveTime值已更新 请展开灵动岛查看")
        }
    }
}

/// 结束灵动岛显示
func endActivity(){
    Task{
        for activity in Activity<RealTimeBusWeightAttributes>.activities{
            await activity.end(dismissalPolicy: .immediate)
            print("已关闭灵动岛显示")
        }
    }
}
