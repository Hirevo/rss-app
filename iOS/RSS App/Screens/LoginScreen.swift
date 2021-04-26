
import SwiftUI

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
            
            Button(action: { presentingSafariView = true }) {
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
        .sheet(isPresented: $presentingSafariView) { webView }
    }

    let googleAuthURL = "https://rss.polomack.eu/auth/google"
    let callbackURL = "https://rss.polomack.eu/"
    var webView: some View {
        NavigationView {
            WebView(url: googleAuthURL, target: callbackURL) { view in
                presentingSafariView = false
                view.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    let cookies = cookies.filter {
                        cookie in cookie.domain == "rss.polomack.eu"
                    }
                    
                    URLSession.shared.configuration.httpCookieStorage?
                        .setCookies(cookies, for: nil, mainDocumentURL: nil)
                    
                    state.refreshSession()
                }
            }
            .navigationBarTitle("Login with Google", displayMode: .inline)
            .navigationBarItems(leading: Button {
                presentingSafariView = false
            } label: {
                Text("Cancel")
            })
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
