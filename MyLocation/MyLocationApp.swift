//
//  MyLocationApp.swift
//  MyLocation
//
//  Created by manabe on 2022/11/11.
//

import SwiftUI
import AppTrackingTransparency
import AdSupport

@main
struct MyLocationApp: App {
    
    // AppDelegateを登録
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView() // SceneDelegateでUIを管理するため空のビューを設定
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            print("Failed to cast UIScene to UIWindowScene")
            return
        }
        
        print("Scene connected successfully")
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()

        // 初回起動時にATTチェックを行う
        checkTrackingPermission()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // アプリがフォアグラウンドになったとき
        print("App became active - starting foreground synchronization.")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // アプリがバックグラウンドに入る直前
        print("App will resign active.")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // アプリがバックグラウンドになったとき
        print("App entered background - starting background synchronization.")
        LocationManager.shared.updateLocation { _ in }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // アプリがフォアグラウンドに戻る直前
        print("App will enter foreground.")
    }

    // ATTチェックを行うメソッド
    func checkTrackingPermission() {
        if #available(iOS 14.5, *) {
            // .notDeterminedの場合にだけリクエスト呼び出しを行う
            guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
            
            // タイミングを遅らせる為に処理を遅延させる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    // リクエスト後の状態に応じた処理を行う
                })
            }
        }
    }
}
