
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var url: String

    func makeNSView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        return WKWebView(frame: .zero, configuration: webConfiguration)
    }

    func updateNSView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
