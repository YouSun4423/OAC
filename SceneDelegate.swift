//
//  SceneDelegate.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2024/09/06.
//
import UIKit
import CoreBluetooth


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // 初回起動判定
        if isFirstLaunch() {
            // 初回起動時の処理
            print("初回起動です")
            return
        }
        print("初回起動ではありません")
    }

    private func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            // UserDefaults.standard.synchronize() はiOS 12以降は必要ありません
            return true // 初回起動
        }
        return false // 初回起動ではない
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // アプリがフォアグラウンドに入ったときの処理
        // BLEスキャンを開始
        //LocationManager.shared.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

    }

    func sceneWillResignActive(_ scene: UIScene) {
        // アプリがバックグラウンドに入る直前の処理
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // バックグラウンドに入ったときの処理
        LocationManager.shared.updateLocation { _ in }
    }
}
