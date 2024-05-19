//
//  BusDetailView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import Alamofire
import SwiftUI

class ViewModel: ObservableObject {
    @Published var busTimeInfo: String = "没有车"
    @Published var arriveTime: Int = 0
    
    // 实时更新灵动岛信息
    func updateActivityTime(){
        if let detailViewData = UserDefaultsManager.shared.getDetailViewData(){
            getTimeStaionLocation(lineName: detailViewData.busDetail.lineName, stationId: detailViewData.stationId, lineId: converToLineId(lineId: detailViewData.busDetail.id))
        }
    }

    // 请求参数
    struct RequestParams: Codable {
        let lineName: String
        let stationId: Int
        let lineId: String
    }
    
    
    struct StationLocation: Decodable {
        let longitude: Double
        let latitude: Double
        let arriveStationName: String
        let timeBusDTOList: [TimeBusDTO]
    }
    
    struct TimeBusDTO: Decodable{
        let level: Int
        let stationDistance: Int
        let arriveTime: Int
    }

    // 获取关注的位置和时间描述
    func getTimeStaionLocation(lineName: String, stationId: Int, lineId: String) {
        print("开始调用实时公交接口")
        let params = RequestParams(lineName: lineName, stationId: stationId, lineId: lineId)
        AF.request("http://47.99.71.232:8083/timeBus/busRealtime", method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                    if responseData.code == 200 {
                            if let dataFromString = responseData.data.data(using: .utf8) {
                                let stationLocation = try JSONDecoder().decode(StationLocation.self, from: dataFromString)
                                DispatchQueue.main.async {
                                    print("\(lineName): 详情成功获取站点位置：\(stationLocation)")
                                    let timeBus = stationLocation.timeBusDTOList
                                    if !timeBus.isEmpty {
                                        let firstTimeBus = timeBus[0]
                                        self.arriveTime = firstTimeBus.arriveTime
                                        var busTimeInfo = ""
                                        for index in 0..<timeBus.count {
                                            if timeBus[index].stationDistance == 0{
                                                busTimeInfo += "第\(index+1)辆车即将到站;"
                                            }else{
                                                busTimeInfo += "第\(index+1)辆车还有\(timeBus[index].stationDistance)站;"
                                            }
                                        }
                                        self.busTimeInfo = busTimeInfo
                                    }
                                    
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
    @State private var showingFavoriteOptions = false
    @State private var favoriteOption: String = ""

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
                                        viewModel.getTimeStaionLocation(lineName: busDetail.lineName, stationId: station.id, lineId: station.lineId)
                                      })
                    }
                }
                .padding(.top, 20)
            }
            Spacer()
        }
        .navigationTitle("线路 \(busDetail.lineName)")
        .navigationBarTitleDisplayMode(.inline)
        .actionSheet(isPresented: $showingFavoriteOptions) {
            ActionSheet(
                title: Text("选择公交关注标志"),
                buttons: FavoriteOption.allCases.map { option in
                    .default(Text(option.displayName)) {
                        favoriteOption = option.rawValue
                        saveFavorite(option: option)
                    }
                } + [.cancel()]
            )
        }

    }

    // 关注/取消关注
    func toggleFavorite() {
        if isFavorite {
            UserDefaultsManager.shared.removeFavorite(busId: busDetail.id)
            isFavorite = false
        } else {
            showingFavoriteOptions = true
        }
    }

    // 检查是否关注
    func checkFavorite() {
        isFavorite = UserDefaultsManager.shared.isFavorite(busId: busDetail.id)
        if isFavorite {
            // Check and update the selectedStationId if the current bus is a favorite
            if let favoriteStationId = UserDefaultsManager.shared.getFavoriteStationId(for: busDetail.id)?.stationId {
                selectedStationId = favoriteStationId
                viewModel.getTimeStaionLocation(lineName: busDetail.lineName, stationId: selectedStationId!, lineId: busDetail.stations[busDetail.stations.count - 1].lineId)
            }
        }else{
            print("没有关注站点,默认选择最后一个")
            selectedStationId = busDetail.stations[busDetail.stations.count - 1].id
            viewModel.getTimeStaionLocation(lineName: busDetail.lineName, stationId: selectedStationId!, lineId: busDetail.stations[busDetail.stations.count - 1].lineId)
        }
    }
    func saveFavorite(option: FavoriteOption) {
        let stationId = selectedStationId ?? busDetail.stations.last?.id ?? 0
//            UserDefaultsManager.shared.saveFavorite(busDetail: busDetail, stationId: stationId, attribute: option.rawValue)
        UserDefaultsManager.shared.saveFavorite(busDetail: busDetail, stationId: stationId,directions: option.displayName)
        isFavorite = true
    }

}
