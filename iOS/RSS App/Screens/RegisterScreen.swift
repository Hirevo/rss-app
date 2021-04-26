
import SwiftUI

struct RegisterScreen: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var presentingSafariView: Bool = false
    @State private var loading = false
    
    @EnvironmentObject private var state: AppState
    
    var onLogin: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("Register to RSS App").font(.title2).bold()
            
            TextField("Email address", text: $email)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
            
            TextField("Name", text: $name)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
            
            SecureField("Password", text: $password, onCommit: register)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
            
            Button(action: register) {
                Text("Register").bold()
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .foregroundColor(BG_COLOR)
            .background(FG_COLOR)
            .clipShape(RoundedRectangle(cornerRadius: 5))

            Button(action: onLogin) {
                Text("Already have an account ?").bold()
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))

            HStack(alignment: .center, spacing: 10) {
                Rectangle().frame(height: 2)
                Text("OR")
                Rectangle().frame(height: 2)
            }

            Button(action: register) {
                HStack {
                    Image("Google")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                    Text("Register with Google").bold()
                }.frame(maxWidth: .infinity)
            }
            .padding(8)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
        }.padding()
        .disabled(loading)
        .sheet(isPresented: $presentingSafariView) { webView }
    }
    
    let googleAuthURL = "http://192.168.1.49:3000/auth/google"
    let callbackURL = "http://192.168.1.49:3000/"
    var webView: some View {
        NavigationView {
            WebView(url: googleAuthURL, target: callbackURL) { view in
                presentingSafariView = false
                view.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    let cookies = cookies.filter {
                        cookie in cookie.domain == "192.168.1.49:3000"
                    }
                    
                    URLSession.shared.configuration.httpCookieStorage?
                        .setCookies(cookies, for: nil, mainDocumentURL: nil)
                    
                    state.refreshSession {
                        
                    }
                }
            }
            .navigationBarTitle("Login with Google", displayMode: .inline)
            .navigationBarItems(leading: Button(
                action: {
                    presentingSafariView = false
                },
                label: {
                    Text("Cancel")
                }
            ))
        }
    }
    
    func register() {
    }
    
    func cancel() {
    }
}

struct RegisterScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterScreen()
    }
}
