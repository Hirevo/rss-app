
import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    let html: String

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let view = UILabel()
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 0
        view.setContentCompressionResistancePriority(.defaultLow,
                                                     for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh,
                                       for: .vertical)
        return view
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<Self>) {
        DispatchQueue.main.async {
            let data = Data(self.html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                uiView.attributedText = attributedString
            }
        }
    }
}
