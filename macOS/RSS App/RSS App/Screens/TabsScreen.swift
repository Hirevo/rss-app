
import SwiftUI

struct TabsScreen: View {
    @State private var selected = 1
    
    var body: some View {
        TabView(selection: $selected) {
            FeedsScreen().tabItem {
                Label("Feeds", systemImage: "list.dash")
            }.tag(1)
            CategoriesScreen().tabItem {
                Label("Categories", systemImage: "square.grid.3x3.fill")
            }.tag(2)
            SettingsScreen().tabItem {
                Label("Settings", systemImage: "gearshape.2.fill")
            }.tag(3)
        }
    }
}

//struct TabsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        TabsScreen()
//    }
//}
