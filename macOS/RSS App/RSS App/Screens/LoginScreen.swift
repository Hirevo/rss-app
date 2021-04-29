
import SwiftUI
import BetterSafariView

struct LoginScreen: View {
    @State private var email: String = "nicolas@polomack.eu"
    @State private var password: String = "test"
    @State private var presentingSafariView: Bool = false
    @State private var loading = false
    
    @EnvironmentObject private var state: AppState
    
    var onRegister: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Login to RSS App").font(.title2).bold()

            TextField("Email address", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password, onCommit: login)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: login) {
                Text("Login").bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RSSAppButtonStyle())

            Button(action: onRegister) {
                Text("Need to register an account ?").bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RSSAppButtonStyle())

            HStack(alignment: .center, spacing: 10) {
                Rectangle().frame(height: 2)
                Text("OR")
                Rectangle().frame(height: 2)
            }
            
            Button(action: loginWithGoogle) {
                HStack {
                    Image("Google")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                    Text("Login with Google").bold()
                }.frame(maxWidth: .infinity)
            }
            .buttonStyle(RSSAppButtonStyle())
        }
        .padding()
        .disabled(loading)
        .webAuthenticationSession(isPresented: $presentingSafariView) {
            WebAuthenticationSession(
                url: URL(string: "https://rss.polomack.eu/auth/google?redirect_url=\("rss-app://".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")!,
                callbackURLScheme: "rss-app"
            ) { callbackURL, error in
                if let callbackURL = callbackURL {
                    let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                    let token = queryItems?.filter({$0.name == "token"}).first
                    if let token = token?.value {
                        state.login(token: token) {
                            loading = false
                        }
                    } else {
                        loading = false
                    }
                }
            }
            .prefersEphemeralWebBrowserSession(false)
        }
    }

    func login() {
        loading = true
        state.login(email: email, password: password) { loading = false }
    }

    func loginWithGoogle() {
        loading = true
        presentingSafariView = true
    }
}

//struct LoginScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginScreen()
//    }
//}
