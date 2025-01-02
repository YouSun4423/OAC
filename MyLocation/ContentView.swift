//
//  ContentView.swift
//  MyLocation
//
//  Created by manabe on 2022/11/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("マップ", systemImage: "map")
                }
            
            QRCodeScanView()
                .tabItem {
                    Label("QRコード", systemImage: "qrcode.viewfinder")
                }
            
            UserLocationView()
                .tabItem {
                    Label("位置追跡", systemImage: "location")
                }
        }
    }
}
