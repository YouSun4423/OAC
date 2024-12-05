//
//  ContentView.swift
//  MyLocation
//
//  Created by manabe on 2022/11/11.
//

import SwiftUI
import MapKit
import AVFoundation

struct ContentView: View {
    @ObservedObject var manager = LocationManager() // 位置情報管理
    @State private var trackingMode = MapUserTrackingMode.follow // ユーザートラッキングモード
    @State private var OACNumber: String = "" // QRコードから取得する固有番号
    @State private var phoneNumber: String = "" // ユーザー入力の電話番号
    @State private var showCamera: Bool = false // QRコードスキャナ表示フラグ
    @State private var errorMessage: String = "" // エラーメッセージ表示用
    @State private var mailAddress: String = "" // エラーメッセージ表示用
    
    
    var body: some View {
        VStack(spacing: 50) {
                    // アコーディオンパネル
                    DisclosureGroup("詳細情報") {
                        VStack(spacing: 20) {
                            // 端末ID
                            Text("端末ID: \(manager.id)").foregroundColor(.gray)
                            
                            // 固有番号表示
                            Text("固有番号: \(OACNumber)").foregroundColor(.gray)
                            
                            // QRコードスキャンボタン
                            Button("QRコードをスキャン") {
                                showCamera = true
                            }
                            .sheet(isPresented: $showCamera) {
                                QRScannerView(completion: handleQRCodeResult)
                            }
                            
                            // 電話番号入力
                            TextField("電話番号を入力", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            // メールアドレス入力
                            TextField("メールアドレスを入力", text: $mailAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            // エラー表示
                            if !errorMessage.isEmpty {
                                Text(errorMessage).foregroundColor(.red)
                            }
                            
                            // 送信ボタン
                            Button("送信") {
                                DispatchQueue.main.async {
                                        manager.postData()
                                    }
                            }
                            .disabled(OACNumber.isEmpty) // 入力がない場合は無効化
                        }
                        .padding()
                    }
                }
        // マップ表示
        Map(coordinateRegion: $manager.region,
            showsUserLocation: true,
            userTrackingMode: $trackingMode)
            .edgesIgnoringSafeArea(.bottom)
    }
    
    // QRコード読み取り結果のハンドリング
    func handleQRCodeResult(_ result: String) {
        if let _ = Int(result), result.count == 10 {
            OACNumber = result
            errorMessage = ""
        } else {
            errorMessage = "QRコードの内容が10桁の整数ではありません。"
        }
    }

    
    // 初回インストール時チェック
    func checkFirstLaunch() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "hasLaunchedBefore") == false {
            // 初回起動時の処理
            defaults.set(true, forKey: "hasLaunchedBefore")
            print("初回起動時の処理を実行")
        }
    }
}
