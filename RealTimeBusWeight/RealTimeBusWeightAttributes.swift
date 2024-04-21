//
//  RealTimeBusWeightLiveActivity.swift
//  RealTimeBusWeight
//
//  Created by 刘帅彪 on 2024/4/20.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RealTimeBusWeightAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var estimatedArrival: Int
    }

    // Fixed non-changing properties about your activity go here!
    var lineName: String
    var stationName: String
}
