//
//  BusDetail.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import Foundation
import Combine

class BusDetail: Identifiable, Codable, ObservableObject {
    let id: Int
    @Published var lineName: String
    @Published var serviceTime: String
    @Published var firstStation: String
    @Published var lastStation: String
    @Published var description: String
    @Published var currentStation: String?
    @Published var stations: [Station]

    enum CodingKeys: CodingKey {
        case id, lineName, serviceTime, firstStation, lastStation, description, currentStation, stations
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        _lineName = Published(initialValue: try container.decode(String.self, forKey: .lineName))
        _serviceTime = Published(initialValue: try container.decode(String.self, forKey: .serviceTime))
        _firstStation = Published(initialValue: try container.decode(String.self, forKey: .firstStation))
        _lastStation = Published(initialValue: try container.decode(String.self, forKey: .lastStation))
        _description = Published(initialValue: try container.decode(String.self, forKey: .description))
        _currentStation = Published(initialValue: try container.decodeIfPresent(String.self, forKey: .currentStation))
        _stations = Published(initialValue: try container.decode([Station].self, forKey: .stations))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lineName, forKey: .lineName)
        try container.encode(serviceTime, forKey: .serviceTime)
        try container.encode(firstStation, forKey: .firstStation)
        try container.encode(lastStation, forKey: .lastStation)
        try container.encode(description, forKey: .description)
        try container.encode(currentStation, forKey: .currentStation)
        try container.encode(stations, forKey: .stations)
    }
}



class Station: Identifiable, Codable, ObservableObject {
    @Published var id: Int
    @Published var stopNumber: Int
    @Published var stopName: String
    @Published var lineId: String
    @Published var isCurrent: Bool?

    enum CodingKeys: CodingKey {
        case id, stopNumber, stopName, lineId, isCurrent
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = Published(initialValue: try container.decode(Int.self, forKey: .id))
        _stopNumber = Published(initialValue: try container.decode(Int.self, forKey: .stopNumber))
        _stopName = Published(initialValue: try container.decode(String.self, forKey: .stopName))
        _lineId = Published(initialValue: try container.decode(String.self, forKey: .lineId))
        _isCurrent = Published(initialValue: try container.decodeIfPresent(Bool.self, forKey: .isCurrent))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(stopNumber, forKey: .stopNumber)
        try container.encode(stopName, forKey: .stopName)
        try container.encode(lineId, forKey: .lineId)
        try container.encode(isCurrent, forKey: .isCurrent)
    }
}
extension Station: Equatable {
    static func == (lhs: Station, rhs: Station) -> Bool {
        // Compare relevant properties to determine equality
        return lhs.id == rhs.id &&
               lhs.stopNumber == rhs.stopNumber &&
               lhs.stopName == rhs.stopName &&
               lhs.lineId == rhs.lineId &&
               lhs.isCurrent == rhs.isCurrent
    }
}


extension BusDetail: Equatable {
    static func == (lhs: BusDetail, rhs: BusDetail) -> Bool {
        // Assuming id is unique for each bus, or compare more properties if needed
        return lhs.id == rhs.id &&
               lhs.lineName == rhs.lineName &&
               lhs.serviceTime == rhs.serviceTime &&
               lhs.firstStation == rhs.firstStation &&
               lhs.lastStation == rhs.lastStation &&
               lhs.description == rhs.description &&
               lhs.currentStation == rhs.currentStation &&
               lhs.stations == rhs.stations
    }
}
extension BusDetail {
    func refresh() {
        // 这里可以是更新实际数据的代码，或者仅仅是触发更新的操作
        self.objectWillChange.send()
    }
}
