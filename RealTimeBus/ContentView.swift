//
//  ContentView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    // 搜索
    @State private var searchText = ""
    // 公交线路数组
    @State private var busLines = [BusDetail]()
    // 访问位置,显示城市公交,比如北京
    @StateObject private var locationManager = LocationManager() // 添加位置管理器的状态对象
    // 根据是否是搜索结果显示不同的样式
    @State private var showingSearchResults = false

    var body: some View {
            NavigationView {
                ZStack {
                    // 搜索结果显示的数据和样式
                    if showingSearchResults {
                        List(filteredBusLines) { busLine in
                            searchResultsView(busLine: busLine)
                        }
                        // 获取当前位置的城市
                        .navigationBarTitle("\(locationManager.city ?? "北京")公交搜索结果")
                        .refreshable {
                            refreshData()
                        }
                    } else {
                        // 获取关注的公交线路
                        List(busLines) { busLine in
                            favoriteBusView(busLine: busLine)
                        }
                        .navigationBarTitle("\(locationManager.city ?? "北京")公交")
                        .refreshable {
                            refreshData()
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "搜索公交线路")
                .onChange(of: searchText) { newValue in
                    showingSearchResults = !newValue.isEmpty
                    if !newValue.isEmpty {
                        fetchBusLines(searchText: newValue)
                    }
                }
                .onAppear {
                    // 请求位置
                    locationManager.requestLocation()
                    if searchText.isEmpty {
                        // 刷新关注公交
                        refreshFavoriteBusLines()
                    }
                    
                    startActivity()
                }
            }
        }
    
    func refreshData() {
        if showingSearchResults {
            fetchBusLines(searchText: searchText)
        } else {
            refreshFavoriteBusLines()
        }
    }



    
    func favoriteBusView(busLine: BusDetail) -> some View {
            ZStack {
                BusRowView(bus: busLine)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Label("love", systemImage: "heart.slash")
                            .tint(.green)
                    }
                    .background(
                        NavigationLink(destination: BusDetailView(busDetail: busLine)) {
                            EmptyView()  // Empty view for the NavigationLink
                        }
                        .opacity(0) // Make NavigationLink completely transparent
                    )
            }
        }
    
    func searchResultsView(busLine: BusDetail) -> some View {
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
    

    // 根据搜索文本过滤线路
    var filteredBusLines: [BusDetail] {
            if searchText.isEmpty {
                return []
            } else {
                return busLines.filter { $0.lineName.contains(searchText) || $0.description.contains(searchText) }
            }
        }
    
    func refreshFavoriteBusLines() {
            // 假设`UserDefaultsManager.shared.getFavoriteBus()`
            // 是同步返回最新的收藏公交线路数组的函数。
            busLines = UserDefaultsManager.shared.getFavoriteBus()
            print("最爱公交线路列表已刷新")
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
