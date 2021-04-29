
import SwiftUI

struct ArticlesScreen: View {
    var feed: Feed
    
    @State private var articles: [Article] = []
    
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var location: AppLocationManager

    var body: some View {
        List {
            if articles.isEmpty {
                Text("No articles").bold().font(.title2).foregroundColor(.secondary).inExpandingRectangle()
            } else {
                ForEach(articles) { article in
                    Button {
                        location.push(.article(article))
                    } label: {
                        HStack(spacing: 10) {
                            Text(article.title).lineLimit(1)

                            Spacer()

                            if article.markedAsRead {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .padding(5)
                        .inExpandingRectangle()
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .buttonStyle(RSSAppButtonStyle())
                }
            }
        }
        .inExpandingRectangle()
        .onAppear {
            self.refreshArticles()
        }
    }
    
    func refreshArticles() {
        state.articles(feedId: feed.id) { maybeArticles in
            if case .some(let articles) = maybeArticles {
                self.articles = articles
            }
        }
    }
}

//struct ArticlesScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        ArticlesScreen()
//    }
//}
