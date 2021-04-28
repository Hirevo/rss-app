
import SwiftUI
import BetterSafariView

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var presentingSafariView: Bool = false
    @State private var loading = false
    
    @EnvironmentObject private var state: AppState
    
    var onRegister: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("Login to RSS App").font(.title2).bold()
            
            TextField("Email address", text: $email)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
            
            SecureField("Password", text: $password, onCommit: login)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
            
            Button(action: login) {
                Text("Login").bold()
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .foregroundColor(BG_COLOR)
            .background(FG_COLOR)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Button(action: onRegister) {
                Text("Need to register an account ?").bold()
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
            
            HStack(alignment: .center, spacing: 10) {
                Rectangle().frame(height: 2)
                Text("OR")
                Rectangle().frame(height: 2)
            }
            
            Button(action: {
                loading = true
                presentingSafariView = true
            }) {
                HStack {
                    Image("Google")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                    Text("Login with Google").bold()
                }.frame(maxWidth: .infinity)
            }
            .padding(8)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
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
}

//struct LoginScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginScreen()
//    }
//}
