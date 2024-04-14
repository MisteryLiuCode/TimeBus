//
//  Common.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/4/8.
//

import Foundation

// 响应数据
struct ResponseData: Codable {
    let code: Int
    let data: String
    let message: String
}

//let host = "localhost"
let host = "47.99.71.232"

let busDataByLineNameUrl = "http://\(host):8083/timeBus/tBusLine/getBusDataByLineName/"
