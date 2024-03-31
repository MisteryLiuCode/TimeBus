//
//  BusDetailView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import Alamofire
import SwiftUI

class ViewModel: ObservableObject {
    @Published var busTimeInfo: String = "加载中..."

    struct ResponseData: Codable {
        let code: Int
        let data: String
        let message: String
    }

    func fetchBusTime() {
        AF.request("http://127.0.0.1:8083/timeBus/bus857").responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(ResponseData.self, from: data)
                    if responseData.code == 200 {
                        // 成功获取数据，更新 busTimeInfo
                        self.busTimeInfo = responseData.data
                    } else {
                        // 其他状态码，根据需要处理或者更新 busTimeInfo
                        self.busTimeInfo = "获取信息失败: \(responseData.message)"
                    }
                } catch {
                    print("解析响应失败: \(error)")
                    self.busTimeInfo = "解析信息失败"
                }
            case .failure(let error):
                print("请求失败: \(error)")
                self.busTimeInfo = "请求信息失败"
            }
        }
    }
}

struct BusDetailView: View {
    // 假设这些数据是通过之前页面传递过来的
    let busDetail: BusDetail
    @StateObject private var viewModel = ViewModel()
    @State private var isFavorite: Bool = false
    var body: some View {
        VStack {
            // 顶部信息卡片
            VStack(alignment: .leading, spacing: 10) {
                Text(busDetail.description)
                    .bold()
                Text(busDetail.operationTime ?? "")
                    .font(.subheadline)
                HStack {
                               Button(action: viewModel.fetchBusTime) {
                                   Text(viewModel.busTimeInfo)
                               }
                               .buttonStyle(.bordered)
                               .tint(.green)
                               Spacer()
                               Button(action: toggleFavorite) {
                                   Label(isFavorite ? "取消关注" : "关注", systemImage: isFavorite ? "bell.fill" : "bell")
                               }
                               .buttonStyle(.bordered)
                           }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .onAppear {
                checkIfFavorite()
                        viewModel.fetchBusTime() // 当视图出现时获取信息
                    }
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
    
    private func toggleFavorite() {
            if isFavorite {
                UserDefaultsManager.shared.removeFavorite(busId: busDetail.id)
            } else {
                UserDefaultsManager.shared.saveFavorite(busId: busDetail.id)
            }
            isFavorite.toggle()
        }
        
        private func checkIfFavorite() {
            isFavorite = UserDefaultsManager.shared.isFavorite(busId: busDetail.id)
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

