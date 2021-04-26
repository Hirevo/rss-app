
import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
   
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(text, baseURL: nil)
    }
}
