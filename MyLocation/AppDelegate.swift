//
//  AppDelegate.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2024/07/19.
//

import UIKit
import SwiftUI
import AppTrackingTransparency
import AdSupport

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {

        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
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
        let settingView = UIHostingController(rootView: SettingsView())

        // タブアイコンとタイトルを設定
        mapView.tabBarItem = UITabBarItem(title: "マップ", image: UIImage(systemName: "map"), tag: 0)
        qrCodeView.tabBarItem = UITabBarItem(title: "QRコード", image: UIImage(systemName: "qrcode.viewfinder"), tag: 1)
        userLocationView.tabBarItem = UITabBarItem(title: "位置追跡", image: UIImage(systemName: "location"), tag: 2)
        settingView.tabBarItem = UITabBarItem(title: "設定", image: UIImage(systemName: "ellipsis.circle"), tag: 3)

        // タブバーにビューを設定
        tabBarController.viewControllers = [mapView, qrCodeView, userLocationView, settingView]

        // ウィンドウのルートビューコントローラーを設定
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }

}
