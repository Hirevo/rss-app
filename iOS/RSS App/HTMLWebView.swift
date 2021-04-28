
import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    var html: String

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        return WKWebView(frame: .zero, configuration: webConfiguration)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
