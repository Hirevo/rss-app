
import SwiftUI

struct CategoryFeedsScreen: View {
    var category: String
    var feeds: [Feed]
    
    var body: some View {
        List {
            if feeds.isEmpty {
                HStack {
                    Spacer()
                    Text("No feeds").foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ForEach(feeds) { feed in
                    NavigationLink(destination: ArticlesScreen(feed: feed)) {
                        Text(feed.title)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(category)
    }
}

//struct CategoryFeedsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryFeedsScreen()
//    }
//}
