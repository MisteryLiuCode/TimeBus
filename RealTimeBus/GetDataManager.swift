//
//  GetDataManager.swift
//  RealTimeBus
//
//  Created by misteryliu on 2024/4/3.
//

import Foundation
import Alamofire
class GetDataManager{

    static let shared = GetDataManager()

    private init() {} // 私有化初始化方法，确保单例的唯一性
    func saveToLocalStorage(data: [BusDetail])  throws {
        print("开始保存数据")
        let filePath = getDocumentsDirectory().appendingPathComponent("busDetails.json")
        let encodedData = try JSONEncoder().encode(data)
        try encodedData.write(to: filePath, options: [.atomicWrite])
    }

    func loadFromLocalStorage()  throws -> [BusDetail] {
        let filePath = getDocumentsDirectory().appendingPathComponent("busDetails.json")
        let data = try Data(contentsOf: filePath)
        let busDetails = try JSONDecoder().decode([BusDetail].self, from: data)
        return busDetails
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
}
