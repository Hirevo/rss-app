
import SwiftUI

let FG_COLOR = Color("AccentColor")
let BG_COLOR = Color("SecondaryColor")

@main
struct RSSApp: App {
    var body: some Scene {
        WindowGroup {
            RootScreen()
                .environmentObject(AppState())
                .background(BG_COLOR)
                .foregroundColor(FG_COLOR)
        }
    }
}
