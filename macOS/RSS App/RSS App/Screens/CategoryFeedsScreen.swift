
import SwiftUI
import WrappingHStack

struct CategoryFeedsScreen: View {
    var category: String
    var feeds: [Feed]

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var location: AppLocationManager

    var body: some View {
        List {
            if feeds.isEmpty {
                Text("No feeds").bold().font(.title2).foregroundColor(.secondary).inExpandingRectangle()
            } else {
                ForEach(feeds) { feed in
                    Button {
                        location.push(.articles(feed))
                    } label: {
                        Text(feed.title).lineLimit(1)
                            .padding(5)
                            .inExpandingRectangle()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .buttonStyle(RSSAppButtonStyle())
                }
            }
        }
        .inExpandingRectangle()
    }
}

//struct CategoryFeedsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedsScreen()
//    }
//}
