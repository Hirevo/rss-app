
import SwiftUI

let FG_COLOR = Color("AccentColor")
let BG_COLOR = Color("SecondaryColor")

@main
struct RSSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(AppState())
        }
    }
}
