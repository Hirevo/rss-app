
import SwiftUI

struct RSSAppButtonStyle: ButtonStyle {
    private struct RSSAppButtonStyleView<V: View>: View {
        @State private var hovered = false

        let content: () -> V

        var body: some View {
            content()
                .padding(5)
                .background(hovered ? FG_COLOR : BG_COLOR)
                .foregroundColor(hovered ? BG_COLOR : FG_COLOR)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .onHover { over in
                    self.hovered = over
                }
        }
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        RSSAppButtonStyleView { configuration.label }
    }
}
