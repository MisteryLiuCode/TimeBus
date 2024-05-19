//
//  ContentView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import SwiftUI
import Alamofire
import Combine

struct ContentView: View {
    @State private var searchText = ""
    @State private var busLines = [BusDetail]()
    @StateObject private var locationManager = LocationManager()
    @State private var showingSearchResults = false
    private var searchSubject = PassthroughSubject<String, Never>()
    private var cancellables: Set<AnyCancellable> = []

    var body: some View {
        NavigationView {
            ZStack {
                if showingSearchResults {
                    List(busLines, id: \.id) { busLine in
                        searchResultsView(busLine: busLine)
                    }
                    .navigationBarTitle("\(locationManager.city ?? "北京")公交")
                    .refreshable {
                        refreshData()
                    }
                } else {
                    List(busLines, id: \.id) { busLine in
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
                searchSubject.send(newValue)
            }
            .onAppear {
                locationManager.requestLocation()
                if searchText.isEmpty {
                    refreshData()
                }
            }
        }
        .onReceive(
            searchSubject
                .debounce(for: .seconds(0.5 ), scheduler: RunLoop.main)
                .removeDuplicates()
        ) { newValue in
            showingSearchResults = !newValue.isEmpty
            if !newValue.isEmpty {
                    let searchParam = SearchBusParam(searchText: newValue)
                    fetchBusLines(searchBusParam: searchParam)
               
            } else {
                refreshData()
            }
        }
        .onDisappear {
            cancellables.forEach { $0.cancel() }
        }
    }


    func refreshData() {
        if showingSearchResults {

                let search = SearchBusParam(searchText: searchText)
                fetchBusLines(searchBusParam: search)
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
//    var filteredBusLines: [BusDetail] {
//            if searchText.isEmpty {
//                return []
//            } else {
//                return busLines.filter { $0.lineName.contains(searchText) || $0.description.contains(searchText) }
//            }
//        }

    func refreshFavoriteBusLines() {
            // 假设`UserDefaultsManager.shared.getFavoriteBus()`
            // 是同步返回最新的收藏公交线路数组的函数。
            busLines = UserDefaultsManager.shared.getFavoriteBus()
            print("最爱公交线路列表已刷新")
        }
    
    struct SearchBusParam :Codable{
        let searchText: String
    }
    struct SearchResult: Decodable {
        let searchText: String
        let lineStationsList: [BusDetail]
    }


    func fetchBusLines(searchBusParam: SearchBusParam) {
//        do {
//            // 读取本地缓存,如果没有再调用接口获取
//            let busLines = try UserDefaultsManager.shared.getSearchData(searchText: searchText)
//            if !busLines.isEmpty {
//                print("使用本地搜索数据")
//                self.busLines = busLines
//                return
//            }
//        } catch {
//            // 如果错误被抛出，就会运行这里的代码
//            print("使用本地搜索数据异常: \(error)")
//        }
        // 本地没有,读取接口数据
        AF.request("\(busDataByLineNameUrl)", method: .post, parameters: searchBusParam, encoder: JSONParameterEncoder.default).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    // 直接解码 ResponseData
                    let responseData = try decoder.decode(ResponseData.self, from: data)
                    if responseData.code == 200 {
                        DispatchQueue.main.async {
                            // 使用data字段上的JSON字符串来解码BusDetail数组
                            if let dataFromString = responseData.data.data(using: .utf8) {
                                do {
                                    let searchResult = try JSONDecoder().decode(SearchResult.self, from: dataFromString)
                                    if self.searchText == searchResult.searchText{
                                        self.busLines = searchResult.lineStationsList
                                        print("成功搜索结果,搜索的关键词:\(searchResult.searchText)")
    //                                    do {
    //                                        print("开始把搜索数据保存到本地")
    //                                        try UserDefaultsManager.shared.savaSearchData(searchText: searchText, data: busLines)
    //                                    } catch {
    //                                        // 如果错误被抛出，就会运行这里的代码
    //                                        print("把搜索数据保存到本地失败: \(error)")
    //                                    }
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
