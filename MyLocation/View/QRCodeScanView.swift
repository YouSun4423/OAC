//
//  QRCodeScan.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2025/01/02.
//

import SwiftUI

struct DismissKeyboardOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color.clear
                    .contentShape(Rectangle()) // 全画面でのタップ検知
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTapModifier())
    }
}


struct QRCodeScanView: View {
    @State private var DeviceId: String = UIDevice.current.identifierForVendor!.uuidString
    @State private var OACNumber: String = "" // QRコードから取得する固有番号
    @State private var phoneNumber: String = "" // ユーザー入力の電話番号
    @State private var mailAddress: String = "" // メールアドレス
    @State private var showCamera: Bool = false // QRコードスキャナ表示フラグ
    @State private var errorMessage: String = "" // エラーメッセージ
    @State private var showAlert: Bool = false // アラート表示フラグ

    var body: some View {
        VStack(spacing: 50) {
            // QRコードスキャンボタン
            Button("QRコードをスキャン") {
                showCamera = true
            }
            .sheet(isPresented: $showCamera) {
                QRScannerView(completion: handleQRCodeResult)
            }
            
            // 固有番号表示
            Text("固有番号: \(OACNumber)").foregroundColor(.gray)
            
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
                postDeviceData()
                showAlert = true // アラートを表示
            }
            .disabled(OACNumber.isEmpty) // 固有番号がない場合は無効化
            }
            .alert(isPresented: $showAlert) {
            Alert(
                title: Text("完了"),
                message: Text("送信ボタンが押されました"),
                dismissButton: .default(Text("OK"))
            )
        }.dismissKeyboardOnTap()
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
    
    func postDeviceData() {
        let baseUrl: String = "http://arta.exp.mnb.ees.saitama-u.ac.jp/oac/common/update_passenger_contact.php"
        
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "oac", value: self.OACNumber),
            URLQueryItem(name: "spid", value: String(self.DeviceId)),
            URLQueryItem(name: "tel", value: String(self.phoneNumber)),
            URLQueryItem(name: "email", value: String(self.mailAddress))
        ]

        guard let url = urlComponents.url else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("データがありません: \(error?.localizedDescription ?? "不明なエラー")")
                return
            }
            
            // サーバーからのレスポンスを文字列として処理
            if let responseString = String(data: data, encoding: .utf8) {
                print("サーバーからのレスポンス: \(responseString)")
            } else {
                print("レスポンスの文字列変換に失敗しました。")
            }
        }
        task.resume()
    }
}
