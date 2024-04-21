//
//  BusRowView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/4/13.
//
import SwiftUI
import Alamofire

// 视图模型
class BusViewModel: ObservableObject {
    @Published var busReatimeInfo: String = "加载中..."
    @Published var longitude: Double = 116.397455
    @Published var latitude: Double = 39.909187
    @Published var mapDesc: String = "加载中..."
    
    
    // 请求参数和响应数据结构
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
    func fetchBusTime(bus: BusDetail) {
        print("开始获取实时公交信息")
        if let favoriteStationId = UserDefaultsManager.shared.getFavoriteStationId(for: bus.id)?.stationId {
        let params = RequestParams(lineName: bus.lineName, stationId: favoriteStationId, lineId: converToLineId(lineId: bus.id))
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
                                self.busReatimeInfo = realTimeInfo.detailDesc
                            }
                        }
                    } else {
                        print("调用实时公交接口获取信息失败: \(responseData.message)")
                    }
                } catch {
                    self.busReatimeInfo = "解析信息失败"
                }
            case .failure(let error):
                self.busReatimeInfo = "请求信息失败"
            }
        }
    }
}
    
    struct StationLocation: Decodable {
        let longitude: Double
        let latitude: Double
        let desc: String
    }

    // 获取关注的staionId，最近一站的经纬度，如果没有，返回关注的站位置
    func getTimeStaionLocation(bus: BusDetail) {
        if let favoriteStationId = UserDefaultsManager.shared.getFavoriteStationId(for: bus.id)?.stationId {
            print("开始获取地图公交信息")
            let params = RequestParams(lineName: bus.lineName, stationId: favoriteStationId, lineId: converToLineId(lineId: bus.id))
            AF.request("http://47.99.71.232:8083/timeBus/busMap", method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                        if responseData.code == 200 {
                            if let dataFromString = responseData.data.data(using: .utf8) {
                                let stationLocation = try JSONDecoder().decode(StationLocation.self, from: dataFromString)
                                DispatchQueue.main.async {
                                    print("成功获取站点位置：\(stationLocation)")
                                    self.longitude = stationLocation.longitude
                                    self.latitude = stationLocation.latitude
                                    self.mapDesc = stationLocation.desc
                                }
                            }
                        } else {
                            print("获取信息失败: \(responseData.message)")
                        }
                    } catch {
                        print("解析信息失败: \(error)")
                    }
                case .failure(let error):
                    print("请求信息失败: \(error)")
                }
            }
        }
    }

}



struct BusRowView: View {
    @ObservedObject var bus: BusDetail
    @StateObject var viewModel = BusViewModel()
    // 创建一个定时器，每10秒触发一次
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // 显示地图
            MapView(latitude: viewModel.latitude, longitude: viewModel.longitude, description: viewModel.mapDesc)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.vertical, 5.0)
                .frame(height: 150)
                .onAppear {
                    print("获取公交实时时间")
                    viewModel.getTimeStaionLocation(bus: bus)
                }.onReceive(viewModel.$mapDesc, perform: { _ in
                    // 当经纬度更新时重新渲染地图
                }).onReceive(timer) { _ in
                    viewModel.getTimeStaionLocation(bus: bus)
                        }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("**\(bus.lineName)**")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true) // Ensures the text wraps within the available space.
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("起点: **\(bus.stations[0].stopName)**")
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("终点: **\(bus.stations[bus.stations.endIndex - 1].stopName)**")
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Image(systemName: "clock")
                        Text("运营时间: **\(bus.serviceTime)**")
                            .font(.caption)
                            .lineLimit(1) // Ensures the text stays within one line.
                            .minimumScaleFactor(0.5) // Allows the text to shrink to fit the space.
                            .padding(5)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black.opacity(0.2), lineWidth: 1))
                            .padding(3)
                    }
                }
                .onAppear {
                    viewModel.fetchBusTime(bus: bus)
                }

                Spacer()

                Text(viewModel.busReatimeInfo)
                    .frame(height: 80)
                    .lineLimit(3) // Allows up to 3 lines for the real-time info.
                    .padding(.horizontal) // Add horizontal padding.
                    .minimumScaleFactor(0.5) // Text will shrink to fit the space if necessary.
                    .multilineTextAlignment(.trailing) // Aligns text to the trailing edge.
                    .onReceive(viewModel.$busReatimeInfo) { _ in
                                            // 这里不需要执行任何代码，因为Text会自动更新
                                        }
            }
        }
    }

}


