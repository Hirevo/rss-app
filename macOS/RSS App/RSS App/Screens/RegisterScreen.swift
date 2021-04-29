
import SwiftUI
import BetterSafariView

struct RegisterScreen: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var presentingSafariView: Bool = false
    @State private var loading = false
    
    @EnvironmentObject private var state: AppState
    
    var onLogin: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Register to RSS App").font(.title2).bold()
            
            TextField("Email address", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password, onCommit: register)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: register) {
                Text("Register").bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RSSAppButtonStyle())

            Button(action: onLogin) {
                Text("Already have an account ?").bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RSSAppButtonStyle())

            HStack(alignment: .center, spacing: 10) {
                Rectangle().frame(height: 2)
                Text("OR")
                Rectangle().frame(height: 2)
            }

            Button(action: registerWithGoogle) {
                HStack {
                    Image("Google")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                    Text("Register with Google").bold()
                }.frame(maxWidth: .infinity)
            }
            .buttonStyle(RSSAppButtonStyle())
        }.padding()
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

    func register() {
        loading = true
        state.register(email: email, name: name, password: password) { loading = false }
    }

    func registerWithGoogle() {
        loading = true
        presentingSafariView = true
    }
}

//struct RegisterScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterScreen()
//    }
//}
