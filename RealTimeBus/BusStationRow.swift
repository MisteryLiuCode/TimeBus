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
            HStack {
                // 如果是当前站点，显示蓝色边框圆圈
                if station.isCurrent ?? false {
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                        .background(Circle().fill(Color.white))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "bus.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(4)
                        )
                }
                
                Text(station.stopName)
                    .foregroundColor(station.isCurrent ?? false ? .blue : .primary)  //使用.primary默认文字颜色
                    .fontWeight(station.isCurrent ?? false ? .bold : .regular)  // 当前站点加粗显示
                
                Spacer()
            }
            .padding()
            .background(station.isCurrent ?? false ? Color.blue.opacity(0.2) : Color(.systemGray6)) // 使用不同的背景色来区分当前站点
            .cornerRadius(10)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)  // 为每项添加阴影
            .padding(.horizontal, 20)  // 增加左右间距
        }
    }
