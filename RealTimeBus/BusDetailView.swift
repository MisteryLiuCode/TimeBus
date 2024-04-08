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

    // 请求参数
    struct RequestParams: Codable {
        let lineName: String
        let stationId: Int
        let lineId: String
    }
    // 调用实时公交接口
    func fetchBusTime(lineName: String, stationId: Int, lineId: String) {
        let params = RequestParams(lineName: lineName, stationId: stationId, lineId: lineId)
        AF.request("http://101.43.145.108:8083/timeBus/busRealtime", method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                    if responseData.code == 200 {
                        DispatchQueue.main.async {
                            self.busTimeInfo = responseData.data
                        }
                    } else {
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
    let busDetail: BusDetail
    @StateObject private var viewModel = ViewModel()
    @State private var isFavorite: Bool = false
    @State private var selectedStationId: Int?
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                // 显示描述信息
                Text(busDetail.description)
                    .bold()
                // 显示服务时间
                Text("运营时间: \(busDetail.serviceTime)")
                    .bold()
                HStack {
                    Button(action: {
                        viewModel.fetchBusTime(lineName: busDetail.lineName, stationId: busDetail.stations[busDetail.stations.count - 1].id, lineId: busDetail.stations[busDetail.stations.count - 1].lineId)
                    }) {
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
                checkFavorite()
            }
            
            HStack {
                Spacer()
                Image(systemName: "bus")
                Text(busDetail.currentStation ?? "")
                    .foregroundColor(.blue)
                Spacer()
            }
            // 线路展示列表
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(busDetail.stations) { station in
                        BusStationRow(station: station,
                                      isSelected: station.id == selectedStationId,
                                      tapAction: {
                                        selectedStationId = station.id  // Set the station as selected
                                        viewModel.fetchBusTime(lineName: busDetail.lineName, stationId: station.id, lineId: station.lineId)
                                      })
                    }
                }
                .padding(.top, 20)
            }
            Spacer()
        }
        .navigationTitle("线路 \(busDetail.lineName)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // 关注/取消站点
    func toggleFavorite() {
        
        if isFavorite{
            UserDefaultsManager.shared.removeFavorite(busId: busDetail.id)
        } else {
            let stationId = selectedStationId ?? busDetail.stations[busDetail.stations.count - 1].id
            UserDefaultsManager.shared.saveFavorite(busId: busDetail.id, stationId: stationId)
        }
        isFavorite.toggle()
    }

    // 检查是否关注
    func checkFavorite() {
        isFavorite = UserDefaultsManager.shared.isFavorite(busId: busDetail.id)
        if isFavorite {
            // Check and update the selectedStationId if the current bus is a favorite
            if let favoriteStationId = UserDefaultsManager.shared.getFavoriteStationId(for: busDetail.id) {
                selectedStationId = favoriteStationId
            }
        }else{
            print("没有关注站点,默认选择最后一个")
            viewModel.fetchBusTime(lineName: busDetail.lineName, stationId: busDetail.stations[busDetail.stations.count - 1].id, lineId: busDetail.stations[busDetail.stations.count - 1].lineId)
        }
    }
}
