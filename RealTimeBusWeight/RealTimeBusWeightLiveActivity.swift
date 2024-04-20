//
//  RealTimeBusWeight.swift
//  RealTimeBusWeight
//
//  Created by 刘帅彪 on 2024/4/20.
//

import WidgetKit
import SwiftUI
import Intents

struct RealTimeBusWeightLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RealTimeBusWeightAttributes.self) { context in
            VStack(spacing: 12) {
                Text("路线：\(context.attributes.lineName)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("即将到达：\(context.attributes.stationName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 8)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemGray6)]), startPoint: .top, endPoint: .bottom))
                        .shadow(radius: 4)
                    
                    HStack {
                        Image(systemName: "bus.fill")
                            .foregroundColor(.black)
                            .imageScale(.large)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("\(context.attributes.estimatedArrival)分钟")
                            .bold()
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 70)
            }
            .padding(.all, 20)
            .background(RoundedRectangle(cornerRadius: 25).fill(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
            .animation(.easeInOut, value: context.attributes.estimatedArrival)
        }
    
    dynamicIsland: { context in
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                Image(systemName: "bus.fill")
            }
            DynamicIslandExpandedRegion(.trailing) {
                Text("\(context.attributes.estimatedArrival)分钟")
                    .font(.headline)
            }
            DynamicIslandExpandedRegion(.center) {
                VStack {
                    Text("路线：\(context.attributes.lineName)")
                        .font(.caption)
                    Text("到站时间")
                        .font(.caption2)
                }
            }
            DynamicIslandExpandedRegion(.bottom) {
                Text("即将到达：\(context.attributes.stationName)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        } compactLeading: {
            Image(systemName: "bus.fill")
                .imageScale(.small)
        } compactTrailing: {
            Text("\(context.attributes.estimatedArrival)分钟")
                .font(.caption2)
        } minimal: {
            Image(systemName: "timer.circle.fill")
                .foregroundColor(.accentColor)
        }
        .widgetURL(URL(string: "http://www.apple.com"))
        .keylineTint(Color.red)
    }
    }
}
