
import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Text("RSS App").font(.title).bold()
        Button {
            state.refreshSession()
        } label: {
            Text("Refresh").bold()
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
