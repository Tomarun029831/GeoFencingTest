// LocationManager.swift

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    @Published var geofenceStatus: String = "モニタリング未開始"
    @Published var currentLocation: CLLocationCoordinate2D?
    
    // 東京駅の座標
    // let geofenceCenter = CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125)
    let geofenceCenter = CLLocationCoordinate2D(latitude: /* Set Latitude */, longitude: /* Set Longitude */)

    override init() {
        super.init()
        locationManager.delegate = self
        // 位置情報更新の精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // バックグラウンドでの位置情報更新を許可
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func requestLocationAuthorization() {
        // ジオフェンシングのために「常に許可」をリクエスト
        locationManager.requestAlwaysAuthorization()
    }
    
    func startGeofencing() {
        let radius: CLLocationDistance = 100 // 100メートル
        let identifier = "TokyoStationGeofence"
        
        // すでに同じジオフェンスが登録されていないか確認
        guard let monitoredRegions = locationManager.monitoredRegions as? Set<CLCircularRegion>,
              !monitoredRegions.contains(where: { $0.identifier == identifier }) else {
            print("ジオフェンスはすでにモニタリング中です。")
            return
        }

        let geofenceRegion = CLCircularRegion(center: geofenceCenter, radius: radius, identifier: identifier)
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: geofenceRegion)
        geofenceStatus = "モニタリングを開始しました: \(identifier)"
        print("ジオフェンシングを開始しました。")
        
        checkGeofenceState()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("位置情報の許可: 常に許可")
            manager.startUpdatingLocation()
            startGeofencing()
        case .authorizedWhenInUse:
            print("位置情報の許可: 使用中のみ")
            geofenceStatus = "エラー: ジオフェンシングには「常に許可」が必要です。"
        case .denied, .restricted:
            print("位置情報の許可: 拒否または制限")
            geofenceStatus = "エラー: 位置情報へのアクセスが拒否されました。"
        case .notDetermined:
            print("位置情報の許可: 未決定")
        @unknown default:
            print("位置情報の許可: 不明なステータス")
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        geofenceStatus = "ジオフェンスに入りました: \(region.identifier)"
        print(geofenceStatus)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        geofenceStatus = "ジオフェンスから出ました: \(region.identifier)"
        print(geofenceStatus)
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            geofenceStatus = "現在、ジオフェンスの内部にいます。"
            print("現在、ジオフェンスの内部にいます。")
        } else if state == .outside {
            geofenceStatus = "現在、ジオフェンスの外部にいます。"
            print("現在、ジオフェンスの外部にいます。")
        } else {
            geofenceStatus = "ジオフェンスの状態は不明です。"
            print("ジオフェンスの状態は不明です。")
        }
    }
    
    // 既存のメソッドの後に、新しいメソッドを追加します
    func checkGeofenceState() {
        let geofenceRegion = CLCircularRegion(center: geofenceCenter, radius: 100, identifier: "TokyoStationGeofence")
        locationManager.requestState(for: geofenceRegion)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location.coordinate
            print("位置情報が更新されました: \(location.coordinate)")
            checkGeofenceState()
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        geofenceStatus = "モニタリング失敗: \(error.localizedDescription)"
        print(geofenceStatus)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
    }
}
