//
//  ContentView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import SwiftUI
import Combine
import Alamofire

struct ContentView: View {
    @StateObject private var viewModel = BusContentViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.showingSearchResults {
                    List(viewModel.busLines, id: \.id) { busLine in
                        searchResultsView(busLine: busLine)
                    }
                    .navigationBarTitle("\(locationManager.city ?? "北京")公交搜索结果")
                } else {
                    List(viewModel.busLines, id: \.id) { busLine in
                        favoriteBusView(busLine: busLine)
                    }
                    .navigationBarTitle("\(locationManager.city ?? "北京")公交")
                    .refreshable {
                        viewModel.loadFavoriteBusLines()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "搜索公交线路")
            .onChange(of: viewModel.searchText) { newValue in
                viewModel.showingSearchResults = !newValue.isEmpty
                viewModel.fetchBusLines(for: newValue)
            }
            .onAppear {
                locationManager.requestLocation()
                if viewModel.searchText.isEmpty {
                    viewModel.loadFavoriteBusLines()
                }
            }
        }
    }

    func favoriteBusView(busLine: BusDetail) -> some View {
        NavigationLink(destination: BusDetailView(busDetail: busLine)) {
            BusRowView(bus: busLine)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Label("Remove", systemImage: "heart.slash").tint(.red)
                }
        }
    }

    func searchResultsView(busLine: BusDetail) -> some View {
        NavigationLink(destination: BusDetailView(busDetail: busLine)) {
            VStack(alignment: .leading) {
                Text(busLine.lineName).fontWeight(.bold)
                Text(busLine.description ?? "").font(.subheadline).foregroundColor(.gray)
            }
        }
    }
}

class BusContentViewModel: ObservableObject {
    @Published var busLines: [BusDetail] = []
    @Published var showingSearchResults: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""

    init() {
        loadFavoriteBusLines()
    }
    
    func fetchBusLines(for searchText: String) {
        guard !searchText.isEmpty else {
            loadFavoriteBusLines()
            return
        }

        // 先检查本地缓存
        do {
            let cachedBusLines = try UserDefaultsManager.shared.getSearchData(searchText: searchText)
            if !cachedBusLines.isEmpty {
                self.busLines = cachedBusLines
                return
            }
        } catch {
            self.errorMessage = "本地数据读取错误: \(error)"
        }

        // 发送网络请求获取数据
        AF.request("\(busDataByLineNameUrl)\(searchText)", method: .get).responseData { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                self.handleSuccess(data: data)
            case .failure(let error):
                self.errorMessage = "网络请求失败: \(error.localizedDescription)"
                self.busLines = []
            }
        }
    }

    private func handleSuccess(data: Data) {
        do {
            let decoder = JSONDecoder()
            let responseData = try decoder.decode(ResponseData.self, from: data)
            if responseData.code == 200, let busLinesData = responseData.data.data(using: .utf8) {
                let busLines = try decoder.decode([BusDetail].self, from: busLinesData)
                DispatchQueue.main.async {
                    self.busLines = busLines
                    UserDefaultsManager.shared.savaSearchData(searchText: self.searchText, data: busLines)
                }
            } else {
                self.errorMessage = "无效的服务器响应码: \(responseData.code)"
            }
        } catch {
            self.errorMessage = "解析数据错误: \(error.localizedDescription)"
        }
    }

    func loadFavoriteBusLines() {
        self.busLines = UserDefaultsManager.shared.getFavoriteBus()
    }
}

