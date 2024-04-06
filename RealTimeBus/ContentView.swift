//
//  ContentView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    @State private var searchText = ""
    @State private var busLines = [BusDetail]()
    @State private var showingSeachResults = false // 新增状态来控制是否显示搜索结果
    @StateObject private var locationManager = LocationManager() // 添加位置管理器的状态对象
    

    var body: some View {
            NavigationView {
                List(filteredBusLines) { busLine in
                    NavigationLink(destination: BusDetailView(busDetail: busLine)) {
                        HStack {
                            Image(systemName: "bus")
                            VStack(alignment: .leading) {
                                Text(busLine.lineName)
                                    .fontWeight(.bold)
                                Text(busLine.description ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationBarTitle("\(locationManager.city ?? "未知")公交", displayMode: .inline)
                // 使用 .searchable 修饰符
                .searchable(text: $searchText, prompt: "搜索公交线路") {
                }
                .onChange(of: searchText) { newValue in // 当搜索文字变化时，更新显示状态
                    showingSeachResults = !newValue.isEmpty
                }
                .onAppear{
                    loadBusLines()
                    locationManager.requestLocation() // 请求位置
                }
            }
        }
    
    // 根据搜索文本过滤线路
    var filteredBusLines: [BusDetail] {
        // 如果searchText为空，则显示所有busLines，否则根据搜索条件过滤
        if searchText.isEmpty {
            // 显示所有关注过的公交线路
                    let favoriteBusIds = UserDefaultsManager.shared.getFavoriteBusIds()
                    return busLines.filter { favoriteBusIds.contains($0.id) }
        } else {
            return busLines.filter { $0.lineName.contains(searchText) || $0.description.contains(searchText) }
        }
    }
    
    // 响应数据
    struct ResponseData: Codable {
        let code: Int
        let data: String
        let message: String
    }
        // 加载本地JSON数据
    func loadBusLines() {
        do {
            // 保存到本地
            let localLineData = try GetDataManager.shared.loadFromLocalStorage()
            if !localLineData.isEmpty {
                self.busLines = localLineData
                return
            }
        } catch {
            // 如果错误被抛出，就会运行这里的代码
            print("读取文件失败: \(error)")
        }
        
        
        
            AF.request("http://localhost:8083/getBusData", method: .post).responseData {response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        // 直接解码 ResponseData
                        let responseData = try decoder.decode(ResponseData.self, from: data)
                        if responseData.code == 200 {
                            DispatchQueue.main.async {
                                // 假定responseData.data实际上包含了JSON格式的BusDetail数组
                                // 使用data字段上的JSON字符串来解码BusDetail数组
                                if let busLinesData = responseData.data.data(using: .utf8) {
                                    do {
                                        let busLines = try decoder.decode([BusDetail].self, from: busLinesData)
                                        print("加载json数据 \(busLines)")
                                        self.busLines = busLines
                                        
                                        do {
                                            // 保存到本地
                                            try GetDataManager.shared.saveToLocalStorage(data: busLines)
                                        } catch {
                                            // 如果错误被抛出，就会运行这里的代码
                                            print("保存文件失败: \(error)")
                                        }
                                        
                                        
                                    } catch {
                                        print("无法解析busLines: \(error)")
                                        self.busLines = []
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.busLines = []
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            print("解析响应错误: \(error)")
                            self.busLines = []
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("请求失败: \(error)")
                        self.busLines = []
                    }
                }
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
