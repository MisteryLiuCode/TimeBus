//
//  LocationManager.swift
//  RealTimeBus
//
//  Created by misteryliu on 2024/4/1.
//

import CoreLocation
import Combine
import Foundation
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var city: String?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() {
           switch locationManager.authorizationStatus {
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
           case .restricted, .denied:
               print("位置服务被禁用或限制")
           case .authorizedWhenInUse, .authorizedAlways:
               locationManager.requestLocation()
           @unknown default:
               fatalError("未处理的授权状态")
           }
       }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization() // 请求用户授权
        locationManager.requestLocation() // 请求一次位置信息
    }
    
    // CLLocationManagerDelegate 方法
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            getCityName(from: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // 从 CLLocation 获取城市名
    private func getCityName(from location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil, let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.city = placemark.locality // 更新城市名称
                }
            }
        }
    }
    

}
