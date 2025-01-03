//
//  PermissionManager.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2025/01/03.
//

import Foundation
import CoreLocation
import AppTrackingTransparency
import UIKit

class PermissionManager {
    
    static let shared = PermissionManager()
    
    private init() {}
    
    // 位置情報とATTの許可をリクエストする
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        requestTrackingPermission { [weak self] trackingGranted in
            guard let self = self else { return }
            
            if trackingGranted {
                print("ATTの許可が得られました")
                requestLocationPermission { locationGranted in
                    completion(locationGranted)
                }
            } else {
                print("ATTの許可が得られませんでした")
                completion(false)
            }
        }
    }
    
    // ATTの許可をリクエストする
    private func requestTrackingPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14.5, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            print("Current tracking status before request: \(status.rawValue)") // 現在のステータスを出力
            

            if status == .notDetermined {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1)  {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        print("Tracking status after request: \(status.rawValue)") // リクエスト後のステータスを出力

                        switch status {
                        case .authorized:
                            completion(true)
                        case .denied, .restricted, .notDetermined:
                            completion(false)
                        @unknown default:
                            completion(false)
                        }
                    }
                }
            } else {
                print("Tracking status already determined: \(status.rawValue)") // すでに決まっている場合のステータスを出力
                completion(status == .authorized)
            }
        } else {
            print("iOS version is below 14.5, assuming tracking is authorized")
            completion(true)
        }
    }

    
    // 許可アラートを表示するメソッド
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "位置情報の許可",
            message: "アプリがバックグラウンドでも位置情報を使用するために、位置情報の常に許可が必要です。設定から許可を変更してください。",
            preferredStyle: .alert
        )
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
    
    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        
        print("call requestLocationPermission")
        let locationManager = CLLocationManager()
        
        locationManager.requestAlwaysAuthorization()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let status = locationManager.authorizationStatus
            completion(status == .authorizedAlways || status == .authorizedWhenInUse)
        }
    }
}

