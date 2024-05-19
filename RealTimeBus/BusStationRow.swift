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
    var isSelected: Bool // New parameter
    var tapAction: () -> Void
    @State private var tap: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: station.isCurrent ?? false ? "bus.fill" : "bus")
                .foregroundColor(station.isCurrent ?? false ? .blue : .gray)
                .frame(width: 24, height: 24)
                .background(station.isCurrent ?? false ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(12)
            VStack(alignment: .leading) {
                Text(station.stopName)
                    .foregroundColor(isSelected ? .red : (station.isCurrent ?? false ? .blue : .primary)) // Use isSelected to modify the color
                    .fontWeight(station.isCurrent ?? false ? .bold : .regular)
                    .lineLimit(1)
                if station.isCurrent ?? false {
                    Text("当前站点")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.5), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
        .scaleEffect(tap ? 0.95 : 1) // 简单的点击效果
        .animation(.easeInOut, value: tap)
        .onTapGesture {
            self.tap = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tap = false
                tapAction()
            }
        }
    }
}
