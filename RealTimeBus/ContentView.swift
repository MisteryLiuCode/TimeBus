//
//  ContentView.swift
//  RealTimeBus
//
//  Created by 刘帅彪 on 2024/3/31.
//

import SwiftUI


struct ContentView: View {
    @State private var searchText = ""
    @State private var busLines = [BusDetail]()
    @State private var showingSeachResults = false // 新增状态来控制是否显示搜索结果
    var body: some View {
            NavigationView {
                List(filteredBusLines) { busLine in
                    NavigationLink(destination: BusDetailView(busDetail: busLine)) {
                        HStack {
                            Image(systemName: "bus")
                            VStack(alignment: .leading) {
                                Text(busLine.line)
                                    .fontWeight(.bold)
                                Text(busLine.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationBarTitle("路线", displayMode: .inline)
                // 使用 .searchable 修饰符
                .searchable(text: $searchText, prompt: "搜索公交线路") {
                }
                .onChange(of: searchText) { newValue in // 当搜索文字变化时，更新显示状态
                    showingSeachResults = !newValue.isEmpty
                }
                .onAppear(perform: loadBusLines)
            }
        }
    
    // 根据搜索文本过滤线路
    var filteredBusLines: [BusDetail] {
        // 如果searchText为空，则显示所有busLines，否则根据搜索条件过滤
        if searchText.isEmpty {
            // 显示所有关注过的公交线路
                    let favoriteBusIds = UserDefaultsManager.shared.getFavorites()
                    return busLines.filter { favoriteBusIds.contains($0.id) }
        } else {
            return busLines.filter { $0.line.contains(searchText) || $0.description.contains(searchText) }
        }
    }
        // 加载本地JSON数据
        func loadBusLines() {
            guard let url = Bundle.main.url(forResource: "bus_lines", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                print("JSON file not found")
                return
            }
            let decoder = JSONDecoder()
            if let busLines = try? decoder.decode([BusDetail].self, from: data) {
                self.busLines = busLines
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
