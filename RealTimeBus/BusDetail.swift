//
//  BusDetail.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import Foundation
struct BusDetail:Identifiable,Codable{
    // 假设这些数据是通过之前页面传递过来的
    let id: Int
    let lineName: String
    let serviceTime: String
    let firstStation: String
    let lastStation: String
    let description: String
    let currentStation: String?
    let stations: [Station]
    
}

struct Station :Identifiable,Codable{
    var id: Int
    var stopNumber: Int
    var stopName: String
    var lineId: String
    var isCurrent:Bool?
}
