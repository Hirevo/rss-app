
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                HStack {
                    Text("Logged in as:")
                    Text(state.profileData?.name ?? "")
                        .bold()
                        .padding(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke())
                }

                HStack {
                    Text("Email:")
                    Text(state.profileData?.email ?? "")
                        .bold()
                        .padding(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke())
                }

                Button {
                    state.logout()
                } label: {
                    Text("Log out")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(FG_COLOR))
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

//struct SettingsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsScreen()
//    }
//}
