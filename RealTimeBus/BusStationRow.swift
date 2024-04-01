//
//  BusStationRow.swift
//  RealTimeBus
//
//  Created by misteryliu on 2024/4/1.
//

import SwiftUI

// 单个公交站的行视图
struct BusStationRow: View {
    let station: Station

    var body: some View {
        HStack(spacing: 15) {  // 增加图标和文本之间的间距
            // 使用系统图标增强视觉效果，特别是对于当前站点
            Image(systemName: station.isCurrent ?? false ? "bus.fill" : "bus")
                .foregroundColor(station.isCurrent ?? false ? .blue : .gray)
                .frame(width: 24, height: 24)
                .background(station.isCurrent ?? false ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(12)  // 当前站点图标背景的圆角

            VStack(alignment: .leading) {
                Text(station.stopName)
                    .foregroundColor(station.isCurrent ?? false ? .blue : .primary)
                    .fontWeight(station.isCurrent ?? false ? .bold : .regular)
                    .lineLimit(1)  // 限制文本行数，避免太长影响布局

                // 可以在这里添加更多的细节信息，如站点编号等
                if station.isCurrent ?? false {
                    Text("当前站点")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(station.isCurrent ?? false ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.5), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}

