//
//  SettingView.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2025/01/03.
//

import SwiftUI
import CoreLocation
import AVFoundation
import AppTrackingTransparency

struct SettingsView: View {
    @State private var locationPermission: CLAuthorizationStatus = .notDetermined
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    @State private var trackingPermission: ATTrackingManager.AuthorizationStatus = .notDetermined

    var body: some View {
        List {
            Section(header: Text("Permissions")) {
                HStack {
                    Text("位置情報")
                    Spacer()
                    Text(permissionDescription(for: locationPermission))
                }
                
                HStack {
                    Text("カメラ")
                    Spacer()
                    Text(permissionDescription(for: cameraPermission))
                }
                
                HStack {
                    Text("トラッキング")
                    Spacer()
                    Text(permissionDescription(for: trackingPermission))
                }
            }
            
            Section(header: Text("設定")) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("アプリ設定")
                    Spacer()
                    
                }.onTapGesture {
                    moveSettings()
                }
                
            }
        }
        .onAppear {
            checkPermissions()
        }
        .navigationTitle("Settings")

        
        
    }
    
    private func moveSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func checkPermissions() {
        locationPermission = CLLocationManager.authorizationStatus()
        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        trackingPermission = ATTrackingManager.trackingAuthorizationStatus
    }
    
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermission = granted ? .authorized : .denied
            }
        }
    }
    
    private func requestTrackingPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                self.trackingPermission = status
            }
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
        
        alert.present(alert, animated: true, completion: nil)
    }
    
    private func permissionDescription(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
    
    private func permissionDescription(for status: AVAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }
    
    private func permissionDescription(for status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }
}
