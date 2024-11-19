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
        VStack(spacing: 20) {
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
                                print("post")
                                postData()
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
    
    func postData() {
        // URLのパーツを個別に作成
        let baseUrl = "http://arta.exp.mnb.ees.saitama-u.ac.jp/oac/common/update_passenger_contact.php"
        
        // リクエストボディに送るデータを辞書形式で作成
        let parameters: [String: Any] = [
            "oac": self.OACNumber,
            "spid": self.manager.id,
            "tel": self.phoneNumber,
            "mail": self.mailAddress
        ]
        
        // URL作成
        guard let url = URL(string: baseUrl) else {
            print("URLが無効です: \(baseUrl)")
            return
        }

        // JSONにエンコード
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            // リクエスト作成
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            // データ送信
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    print("データがありません: \(error?.localizedDescription ?? "不明なエラー")")
                    return
                }
                
                // サーバーからのレスポンスを確認
                if let responseString = String(data: data, encoding: .utf8) {
                    print("サーバーからのレスポンス: \(responseString)")
                }


            }
            task.resume()
            
        } catch let error {
            print("JSONエンコードエラー: \(error)")
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
