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

func converToLineId(lineId: Int) -> String {
    // 使用格式化字符串来指定输出长度和前导零
    return String(format: "%015d", lineId)
}
