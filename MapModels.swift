//
//  MapModels.swift
//  MyLocation
//
//  Created by manabe on 2022/11/11.
//
import CoreLocation
import MapKit


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private var myDeviceId: String = UIDevice.current.identifierForVendor!.uuidString
    private var myLatitude: Double = 0
    private var myLongitude: Double = 0
    private var myAltitude: Double = 0
    private var myFloor: Int = 0
    private var timestamp = { let f = DateFormatter(); f.dateFormat = "yyyyMMddHHmmss"; f.timeZone = TimeZone.current; return f.string(from: Date()) }()
    
    var id: String {
        return myDeviceId
    }
    
    var lat: Double {
        return myLatitude
    }
    
    var lon: Double {
        return myLongitude
    }

    var alt: Double {
        return myAltitude
    }

    var fl: Int {
        return myFloor
    }

    let manager = CLLocationManager()
    
    // region を @Published にして、ビューと連携する
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization() // 常に位置情報を利用許可をリクエスト
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5 //5mごとに位置情報を更新
        manager.allowsBackgroundLocationUpdates = true // バックグラウンド更新を許可
        manager.pausesLocationUpdatesAutomatically = false // 自動的に位置情報更新を一時停止しない
        manager.activityType = .other
        
        checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() {
        let status = manager.authorizationStatus
        if status != .authorizedAlways {
            DispatchQueue.main.async {
                self.showAuthorizationAlert()
            }
        }
    }
    
    private func showAuthorizationAlert() {
        let alert = UIAlertController(title: "位置情報の許可",
                                      message: "アプリがバックグラウンドでも位置情報を使用するために、位置情報の常に許可が必要です。設定から許可を変更してください。",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "設定へ移動", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            checkAuthorizationStatus()
        }
    }

    func updateLocation(completion: @escaping (Bool) -> Void) {
        manager.requestLocation()
        completion(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 新しい位置情報を元に中心座標を更新
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // regionの中心座標を更新
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: center, span: self.region.span)
        }

        // その他の位置情報を更新
        myLatitude = location.coordinate.latitude
        myLongitude = location.coordinate.longitude
        myAltitude = location.altitude
        myFloor = location.floor?.level ?? 0
        
        // 現在の日時を取得
        let currentDate = Date()

        // 日付フォーマットを設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        // フォーマット済みの文字列を取得
        timestamp = formatter.string(from: currentDate)
        
        // 位置情報が有効である場合にのみデータを送信
        if myLatitude != 0 && myLongitude != 0 {
            DispatchQueue.main.async {
                            self.postData()
            }
        }
    }
    
    func postData() {
        let baseUrl: String = "http://arta.exp.mnb.ees.saitama-u.ac.jp/oac/common/post_location.php"
        
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "dev", value: self.myDeviceId),
            URLQueryItem(name: "lat", value: String(self.myLatitude)),
            URLQueryItem(name: "lon", value: String(self.myLongitude)),
            URLQueryItem(name: "ts", value: String(self.timestamp))
        ]

        guard let url = urlComponents.url else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("データがありません: \(error?.localizedDescription ?? "不明なエラー")")
                return
            }
            
            // サーバーからのレスポンスを文字列として処理
            if let responseString = String(data: data, encoding: .utf8) {
                print("サーバーからのレスポンス: \(responseString)")
            } else {
                print("レスポンスの文字列変換に失敗しました。")
            }
        }
        task.resume()
    }

    
    func updateLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .denied {
            print("Location access denied by the user.")
            // 必要ならばユーザーに許可を促す処理を追加
        } else {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
    }
}
