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
    
    func fetchBusTime(lineName: String, stationId: Int, lineId: String) {
        print("开始获取实时公交信息")
        let params = RequestParams(lineName: lineName, stationId: stationId, lineId: lineId)
        AF.request("http://101.43.145.108:8083/timeBus/busRealtime", method: .post, parameters: params, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                    if responseData.code == 200 {
                        DispatchQueue.main.async {
                            self.busReatimeInfo = responseData.data
                        }
                    } else {
                        self.busReatimeInfo = "获取信息失败: \(responseData.message)"
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

// 请求参数和响应数据结构
struct RequestParams: Codable {
    let lineName: String
    let stationId: Int
    let lineId: String
}

struct BusRowView: View {
    var bus: BusDetail
    @ObservedObject var viewModel = BusViewModel()
    
    
    var body: some View {
        VStack {
            MapView(searchString: "北京")
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.vertical, 5.0)
                .frame(height: 150)

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
                    viewModel.fetchBusTime(lineName: bus.lineName, stationId: bus.stations.last!.id, lineId: bus.stations.last!.lineId)
                }

                Spacer()

                Text(viewModel.busReatimeInfo)
                    .frame(height: 80)
                    .lineLimit(3) // Allows up to 3 lines for the real-time info.
                    .padding(.horizontal) // Add horizontal padding.
                    .minimumScaleFactor(0.5) // Text will shrink to fit the space if necessary.
                    .multilineTextAlignment(.trailing) // Aligns text to the trailing edge.
            }
        }
    }

}


