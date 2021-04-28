
import SwiftUI

struct LandingScreen: View {
    @State private var registering = false

    var body: some View {
        if registering {
            RegisterScreen(onLogin: {
                registering = false
            })
        } else {
            LoginScreen(onRegister: {
                registering = true
            })
        }
    }
}

//struct LandingScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        LandingScreen()
//    }
//}
