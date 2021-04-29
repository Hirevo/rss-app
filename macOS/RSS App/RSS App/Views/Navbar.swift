
import SwiftUI

struct Navbar<Label: View>: View {

    var canGoBack: Bool
    var onBack: () -> Void
    var label: () -> Label

    @State private var hovered = false

    var body: some View {
        HStack(spacing: 10) {
            if canGoBack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "arrow.backward")
                        .inRectangle(width: 75)
                }
                .buttonStyle(RSSAppButtonStyle())
            }

            HStack {
                Spacer()
                label()
                Spacer()
            }
        }
        .padding(2)
        .frame(height: 50)
    }
}

//struct Navbar_Previews: PreviewProvider {
//    static var previews: some View {
//        Navbar()
//    }
//}
