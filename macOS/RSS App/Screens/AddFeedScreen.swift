
import SwiftUI

struct AddFeedScreen: View {
    @State private var url: String = ""
    
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var onDismiss: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Feed URL")) {
                TextField("Feed URL", text: $url)
                    .disableAutocorrection(true)
            }
            
            Section {
                HStack {
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
                    
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cancel").bold()
                            Spacer()
                        }
                    }
                    
                }
            }
        }
        .padding()
    }
}

//struct AddFeedScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        AddFeedScreen()
//    }
//}
