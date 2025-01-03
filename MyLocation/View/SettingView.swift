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
                .onTapGesture {
                    requestLocationPermission()
                }
                
                HStack {
                    Text("カメラ")
                    Spacer()
                    Text(permissionDescription(for: cameraPermission))
                }
                .onTapGesture {
                    requestCameraPermission()
                }
                
                HStack {
                    Text("トラッキング")
                    Spacer()
                    Text(permissionDescription(for: trackingPermission))
                }
                .onTapGesture {
                    requestTrackingPermission()
                }
            }
        }
        .onAppear {
            checkPermissions()
        }
        .navigationTitle("Settings")
    }
    
    private func checkPermissions() {
        locationPermission = CLLocationManager.authorizationStatus()
        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        trackingPermission = ATTrackingManager.trackingAuthorizationStatus
    }
    
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
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
