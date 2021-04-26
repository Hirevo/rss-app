
import SwiftUI
import CoreData

struct RootScreen: View {
    @EnvironmentObject private var state: AppState

    @State private var initialized = false

    var body: some View {
        VStack {
            if initialized {
                if state.loggedIn {
                    VStack {
                        VStack(alignment: .center, spacing: 5) {
                            Text("Logged in as:")
                            Text(state.email!).bold()
                        }
                        Button {
                            state.logout()
                        } label: {
                            Text("Log out")
                        }
                    }.font(.title2)
                } else {
                    LandingScreen()
                }
            } else {
                SplashScreen()
            }
        }.onAppear {
            state.refreshSession {
                initialized = true
            }
        }
    }
}

//struct RootScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        RootScreen().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
