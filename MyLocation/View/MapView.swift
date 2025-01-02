//
//  MapView.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2025/01/02.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var manager = LocationManager() // 位置情報管理
    @State private var trackingMode = MapUserTrackingMode.follow // ユーザートラッキングモード

    var body: some View {
        VStack {
            // マップ表示
            Map(coordinateRegion: $manager.region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode)
                .edgesIgnoringSafeArea(.top) // タブバーは無視しない
        }
    }
}
