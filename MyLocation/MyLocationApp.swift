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
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        print("初回起動")
        
        // 初回起動時に位置情報とATTの許可をリクエスト
        PermissionManager.shared.requestPermissions { granted in
            if granted {
                print("すべての許可が得られました")
            } else {
                print("許可が得られませんでした")
            }
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("App became active - starting foreground synchronization.")
        //PermissionManager.shared.checkAuthorizationStatus()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("App will resign active.")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("App entered background - starting background synchronization.")
        LocationManager.shared.updateLocation { _ in }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("App will enter foreground.")
    }
}
