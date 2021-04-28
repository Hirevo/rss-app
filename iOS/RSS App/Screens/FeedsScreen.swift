
import SwiftUI

struct FeedsScreen: View {
    @State private var feeds: [Feed] = []

    @EnvironmentObject private var state: AppState

    @State private var addingFeed = false

    var body: some View {
        NavigationView {
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
                            Text(feed.title).lineLimit(1)
                        }
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
            .listStyle(PlainListStyle())
            .navigationTitle("Feeds")
            .navigationBarItems(trailing: Button {
                addingFeed = true
            } label: {
                Text("Add Feed")
            })
        }
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
