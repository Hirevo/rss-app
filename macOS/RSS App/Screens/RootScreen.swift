
import SwiftUI

struct RootScreen: View {
    @EnvironmentObject private var state: AppState

    @State private var initialized = false

    var body: some View {
        VStack {
            if state.loggedIn {
                BaseScreen()
            } else {
                LandingScreen()
                    .frame(maxWidth: 600)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//struct RootScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        RootScreen().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
