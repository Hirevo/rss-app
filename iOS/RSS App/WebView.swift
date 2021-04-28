
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: String

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        return WKWebView(frame: .zero, configuration: webConfiguration)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
