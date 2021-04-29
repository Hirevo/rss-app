
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()

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
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .inRectangle(width: 300)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .buttonStyle(RSSAppButtonStyle())

            Spacer()
        }
        .padding()
    }
}

//struct SettingsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsScreen()
//    }
//}
