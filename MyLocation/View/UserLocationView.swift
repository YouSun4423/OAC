//
//  UserLocationView.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2025/01/02.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct UserLocationView: View {
    @State private var deviceId: String = UIDevice.current.identifierForVendor!.uuidString
    
    private var date: String {
            dateFormatter()
    }
    
    var body: some View {
        VStack {
            WebView(url: generateURL())
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    // クエリ付きURLを生成
    func generateURL() -> URL {
        
        var components = URLComponents(string: "http://arta.exp.mnb.ees.saitama-u.ac.jp/oac/common/show_location.php")!
        components.queryItems = [
            URLQueryItem(name: "dev", value: deviceId),
            URLQueryItem(name: "date", value: date)
        ]
        return components.url!
    }
    
    func dateFormatter() -> String{
        /// DateFomatterクラスのインスタンス生成
        let dateFormatter = DateFormatter()
         
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        //dateFormatter.locale = Locale(identifier: "ja_JP")
        //dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
         
        /// 変換フォーマット定義
        dateFormatter.dateFormat = "yyyy-MM-dd"
         
        /// データ変換（Date→テキスト）
        let dateString = dateFormatter.string(from: Date())
        
        return dateString
    }
}
