//
//  LocationManager.swift
//  RealTimeBus
//
//  Created by misteryliu on 2024/4/1.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        self.locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization() // 请求用户授权
        locationManager.requestLocation() // 请求一次位置信息
    }
    
    // CLLocationManagerDelegate 方法
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
