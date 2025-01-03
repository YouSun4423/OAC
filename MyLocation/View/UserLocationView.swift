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
    @State private var currentDate: String = ""
    
    var body: some View {
        VStack {
            WebView(url: generateURL())
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    updateDate()
                }
        }
    }
    
    // クエリ付きURLを生成
    func generateURL() -> URL {
        
        var components = URLComponents(string: "http://arta.exp.mnb.ees.saitama-u.ac.jp/oac/common/show_location.php")!
        components.queryItems = [
            URLQueryItem(name: "dev", value: deviceId),
            URLQueryItem(name: "date", value: currentDate)
        ]
        return components.url!
    }
    
    func updateDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            currentDate = dateFormatter.string(from: Date())
    }
}
