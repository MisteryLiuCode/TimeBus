//
//  BusDetailView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import SwiftUI

struct BusDetailView: View {
    // 假设这些数据是通过之前页面传递过来的
    let busDetail: BusDetail

    var body: some View {
        VStack {
            // 顶部信息卡片
            VStack(alignment: .leading, spacing: 10) {
                Text(busDetail.description)
                    .bold()
                Text(busDetail.operationTime ?? "")
                    .font(.subheadline)
                HStack {
                    Button(action: {}) {
                        Text("前方未发车")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    Spacer()
                    Button(action: {}) {
                        Label("关注", systemImage: "bell")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            // 当前位置指示
            HStack {
                Spacer()
                Image(systemName: "bus")
                Text(busDetail.currentStation ?? "")
                    .foregroundColor(.blue)
                Spacer()
            }

            // 站点列表
            List(busDetail.stations ?? [Station]()) { station in
                HStack {
                    if station.isCurrent {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.blue)
                        Text(station.stationName)
                            .foregroundColor(.blue)
                    } else {
                        Text(station.stationName)
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("线路 \(busDetail.line)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BusDetailView(busDetail:
                        BusDetail(
            id: 201,
            line: "201",
            operationTime: "5:30-17:30 未 9:00-22:00",
            currentStation: "中山门",
            description:"",
            stations: [
                Station(id: 1, stationName: "起始站", isCurrent: false),
                // ... 更多站点
                Station(id: 15, stationName: "中山门", isCurrent: true),
                // ... 更多站点
                Station(id: 20, stationName: "终点站", isCurrent: false)
            ]
            )
        )
    }
}

