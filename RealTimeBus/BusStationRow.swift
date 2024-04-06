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
        .onTapGesture {
            tapAction() // Call the closure when the row is tapped
        }
        .padding()
        // Update background or border here based on isSelected, if needed
        .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.5), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}
