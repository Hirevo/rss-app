
import SwiftUI
import WebKit

struct HTMLWebView: NSViewRepresentable {
    var html: String

    func makeNSView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        return WKWebView(frame: .zero, configuration: webConfiguration)
    }

    func updateNSView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
