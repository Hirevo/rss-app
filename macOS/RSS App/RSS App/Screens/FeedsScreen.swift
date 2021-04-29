
import SwiftUI
import WrappingHStack

struct FeedsScreen: View {
    @State private var feeds: [Feed] = []

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var location: AppLocationManager

    @State private var addingFeed = false

    var body: some View {
        List {
            Button {
                addingFeed = true
            } label: {
                Text("Add Feed")
            }
            .buttonStyle(RSSAppButtonStyle())

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
                }.onDelete { indexSet in
                    let group = DispatchGroup()

                    indexSet.forEach { index in
                        group.enter()
                        state.deleteFeed(feedId: self.feeds[index].id) {
                            group.leave()
                        }
                    }

                    group.notify(queue: DispatchQueue.main) {
                        self.feeds.remove(atOffsets: indexSet)
                    }
                }
            }
        }
        .inExpandingRectangle()
        .onAppear {
            self.refreshFeeds()
        }
        .sheet(isPresented: $addingFeed, content: {
            AddFeedScreen {
                self.refreshFeeds()
            }
        })
    }

    func refreshFeeds() {
        state.feeds { maybeFeeds in
            if case .some(let feeds) = maybeFeeds {
                self.feeds = feeds
            }
        }
    }
}

//struct FeedsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedsScreen()
//    }
//}
