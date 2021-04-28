
import SwiftUI

struct AddFeedScreen: View {
    @State private var url: String = ""
    
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode

    var onDismiss: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Feed URL")) {
                    TextField("Feed URL", text: $url)
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                }
                
                Section {
                    Button {
                        self.state.addFeed(feedUrl: url) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Add Feed").bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitle("Add Feed", displayMode: .inline)
            .navigationBarItems(trailing: Button {
                self.state.addFeed(feedUrl: url) {
                    onDismiss()
                    self.presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Add")
            })
            .background(Color.secondary)
        }
    }
}

//struct AddFeedScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        AddFeedScreen()
//    }
//}
