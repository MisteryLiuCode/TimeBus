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
    @Published var arriveTime: Int = -1
    
    // 实时更新灵动岛信息
    func updateActivityTime(){
        if let detailViewData = UserDefaultsManager.shared.getDetailViewData(){
            fetchBusTime(lineName: detailViewData.busDetail.lineName, stationId: detailViewData.stationId, lineId: converToLineId(lineId: detailViewData.busDetail.id))
        }
    }

    // 请求参数
    struct RequestParams: Codable {
        let lineName: String
        let stationId: Int
        let lineId: String
    }
    // 调用实时公交接口
    struct RealTimeInfo: Decodable {
        let detailDesc: String
        let arriveTime: Int
    }
    func fetchBusTime(lineName: String, stationId: Int, lineId: String) {
        print("开始调用实时公交接口")
        let params = RequestParams(lineName: lineName, stationId: stationId, lineId: lineId)
        AF.request("http://47.99.71.232:8083/timeBus/busRealtime", method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                    if responseData.code == 200 {
                        if let dataFromString = responseData.data.data(using: .utf8) {
                            let realTimeInfo = try JSONDecoder().decode(RealTimeInfo.self, from: dataFromString)
                            DispatchQueue.main.async {
                                print("调用实时公交接口结果：\(realTimeInfo)")
                                self.busTimeInfo = realTimeInfo.detailDesc
                                self.arriveTime = realTimeInfo.arriveTime
                            }
                        }
                    } else {
                        print("调用实时公交接口获取信息失败: \(responseData.message)")
                    }
                } catch {
                    print("调用实时公交接口解析信息失败: \(error)")
                }
            case .failure(let error):
                print("调用实时公交接口请求失败: \(error)")
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
    // 创建一个定时器，每10秒触发一次
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
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
            .onReceive(timer) { _ in
                viewModel.updateActivityTime()
                    }
            .onReceive(viewModel.$arriveTime) { newValue in
                        updateActivity(arriveTime: newValue)
                    }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .onAppear {
                endActivity()
                checkFavorite()
                startActivity(busDetail: busDetail,favoriteStationId:selectedStationId ?? busDetail.stations[busDetail.stations.count - 1].id,arriveTime: viewModel.arriveTime)
                UserDefaultsManager.shared.removeDetailViewData()
                UserDefaultsManager.shared.savaDetailViewData(busDetail: busDetail, stationId: selectedStationId!)
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
            UserDefaultsManager.shared.saveFavorite(busDetail: busDetail, stationId: stationId)
        }
        isFavorite.toggle()
    }

    // 检查是否关注
    func checkFavorite() {
        isFavorite = UserDefaultsManager.shared.isFavorite(busId: busDetail.id)
        if isFavorite {
            // Check and update the selectedStationId if the current bus is a favorite
            if let favoriteStationId = UserDefaultsManager.shared.getFavoriteStationId(for: busDetail.id)?.stationId {
                selectedStationId = favoriteStationId
                viewModel.fetchBusTime(lineName: busDetail.lineName, stationId: selectedStationId!, lineId: busDetail.stations[busDetail.stations.count - 1].lineId)
            }
        }else{
            print("没有关注站点,默认选择最后一个")
            selectedStationId = busDetail.stations[busDetail.stations.count - 1].id
            viewModel.fetchBusTime(lineName: busDetail.lineName, stationId: selectedStationId!, lineId: busDetail.stations[busDetail.stations.count - 1].lineId)
        }
    }
}
