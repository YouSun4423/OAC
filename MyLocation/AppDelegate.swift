//
//  AppDelegate.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2024/07/19.
//

import UIKit
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 位置情報の更新やデータの取得をここで行う
        // 例えばLocationManagerのインスタンスを作成して位置情報を取得する
        let locationManager = LocationManager()
        locationManager.updateLocation() // 必要なロジックを追加
        
        completionHandler(.newData)
    }
    
    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            
            application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
            
            // タブバーコントローラーをセットアップ
            let tabBarController = UITabBarController()

            // SwiftUIビューを統合
            let mapView = UIHostingController(rootView: MapView())
            let qrCodeView = UIHostingController(rootView: QRCodeScanView())
            let userLocationView = UIHostingController(rootView: UserLocationView())

            // タブアイコンとタイトルを設定
            mapView.tabBarItem = UITabBarItem(title: "マップ", image: UIImage(systemName: "map"), tag: 0)
            qrCodeView.tabBarItem = UITabBarItem(title: "QRコード", image: UIImage(systemName: "qrcode.viewfinder"), tag: 1)
            userLocationView.tabBarItem = UITabBarItem(title: "位置追跡", image: UIImage(systemName: "location"), tag: 2)

            // タブバーにビューを設定
            tabBarController.viewControllers = [mapView, qrCodeView, userLocationView]

            // ウィンドウのルートビューコントローラーを設定
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()

            return true
        }
}

