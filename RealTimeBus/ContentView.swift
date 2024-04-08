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
            ZStack {
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
                .searchable(text: $searchText, prompt: "搜索公交线路")
                .onChange(of: searchText) { newValue in
                    showingSeachResults = !newValue.isEmpty
                    // 当searchText改变时调用API
                    fetchBusLines(searchText: newValue)
                }
            }
            .onAppear{
                locationManager.requestLocation()
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

    
    func fetchBusLines(searchText: String) {
        do {
            // 读取本地缓存,如果没有再调用接口获取
            let busLines = try UserDefaultsManager.shared.getSearchData(searchText: searchText)
            if !busLines.isEmpty {
                print("使用本地搜索数据")
                self.busLines = busLines
                return
            }
        } catch {
            // 如果错误被抛出，就会运行这里的代码
            print("使用本地搜索数据异常: \(error)")
        }
        // 本地没有,读取接口数据
        AF.request("\(busDataByLineNameUrl)\(searchText)", method: .get).responseData {response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    // 直接解码 ResponseData
                    let responseData = try decoder.decode(ResponseData.self, from: data)
                    if responseData.code == 200 {
                        DispatchQueue.main.async {
                            // 使用data字段上的JSON字符串来解码BusDetail数组
                            if let busLinesData = responseData.data.data(using: .utf8) {
                                do {
                                    let busLines = try decoder.decode([BusDetail].self, from: busLinesData)
                                    self.busLines = busLines
                                    do {
                                        print("开始把搜索数据保存到本地")
                                        try UserDefaultsManager.shared.savaSearchData(searchText: searchText, data: busLines)
                                    } catch {
                                        // 如果错误被抛出，就会运行这里的代码
                                        print("把搜索数据保存到本地失败: \(error)")
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
