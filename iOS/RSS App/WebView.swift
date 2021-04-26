
import SwiftUI
import WebKit

class ObservedVars: ObservableObject {
    var observation: NSKeyValueObservation?
}

// UIViewRepresentable, wraps UIKit views for use with SwiftUI
struct WebView: UIViewRepresentable {
    var url: String
    var target: String

    private var targetUrl: URL? {
        return URL(string: target)
    }

    var onCompletion: (WKWebView) -> Void = { _ in }

    @ObservedObject private var vars = ObservedVars()

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        return WKWebView(frame: .zero, configuration: webConfiguration)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        vars.observation = uiView.observe(\WKWebView.title, options: .new) { view, change in
            if view.url?.equivalent(other: targetUrl!) ?? false {
                onCompletion(view)
            }
        }

        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

extension URL {
    func equivalent(other: Self) -> Bool {
        return self.scheme == other.scheme
            && self.user == other.user
            && self.password == other.password
            && self.host == other.host
            && self.port == other.port
            && self.path == other.path
            && self.query == other.query
    }
}
