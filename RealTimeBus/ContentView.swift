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

//    var body: some View {
//        NavigationView {
//            ZStack {
//                List(filteredBusLines) { busLine in
//                    NavigationLink(destination: BusDetailView(busDetail: busLine)) {
//                        HStack {
//                            Image(systemName: "bus")
//                            VStack(alignment: .leading) {
//                                Text(busLine.lineName)
//                                    .fontWeight(.bold)
//                                Text(busLine.description ?? "")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                    }
//                }
//                .navigationBarTitle("\(locationManager.city ?? "未知")公交", displayMode: .inline)
//                .searchable(text: $searchText, prompt: "搜索公交线路")
//                .onChange(of: searchText) { newValue in
//                    showingSeachResults = !newValue.isEmpty
//                    if !newValue.isEmpty{
//                        // 当searchText改变时调用API
//                        fetchBusLines(searchText: newValue)
//                    }
//                }
//            }
//            .onAppear{
//                locationManager.requestLocation()
//                refreshFavoriteBusLines()
//            }
//        }
//    }
    
    
    var body: some View {
        
        TabView {
            NavigationView {
                ZStack {
                    List(filteredBusLines) { busLine in
                        
                        BusRowView(bus: busLine)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Label("love", systemImage: "heart.slash")
                                .tint(.green)
                                
                            }
                            .listStyle(PlainListStyle())
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.blue)
//                            .onTapGesture {
//                                selectedBus = bus
//                            }
                        
                        
                    }
                        .navigationBarTitle("\(locationManager.city ?? "未知")公交", displayMode: .inline)
                        .searchable(text: $searchText, prompt: "搜索公交线路")
                        .onChange(of: searchText) { newValue in
                            showingSeachResults = !newValue.isEmpty
                            if !newValue.isEmpty{
                                // 当searchText改变时调用API
                                fetchBusLines(searchText: newValue)
                            }
                        }
                    .onAppear{
                        locationManager.requestLocation()
                        refreshFavoriteBusLines()
                    }
                    .refreshable { refreshFavoriteBusLines() }
//                    .searchable(text: $search.animation(), prompt: "Filter")
                    
//                    if let selectedBus = selectedBus {
//                        AsyncImage(url: URL(string: selectedBus.image)) { image in
//                            image
//                                .resizable()
//                                .cornerRadius(10)
//                        } placeholder: {
//                            Image(systemName: "bus")
//                        }
//                        .frame(width: 275, height: 275)
//                        .padding(20)
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(25)
//                        .onTapGesture {
//                            self.selectedBus = nil
//                        }
//                    }
                }
            }
        }
    }
    
    
    

    // 根据搜索文本过滤线路
    var filteredBusLines: [BusDetail] {
        // 如果searchText为空，则显示所有busLines，否则根据搜索条件过滤
        if searchText.isEmpty {
            print("搜索框为空,显示所有关注过的公交线路")
            // 显示所有关注过的公交线路
            return UserDefaultsManager.shared.getFavoriteBus()
        } else {
            print("显示搜索内容")
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
