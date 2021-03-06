
import SwiftUI

struct ArticlesScreen: View {
    var feed: Feed
    
    @State private var articles: [Article] = []
    
    @EnvironmentObject private var state: AppState
    
    var body: some View {
        List {
            if articles.isEmpty {
                HStack {
                    Spacer()
                    Text("No articles").foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ForEach(articles) { article in
                    NavigationLink(destination: ArticleScreen(article: article)) {
                        HStack(spacing: 10) {
                            Text(article.title).lineLimit(1)

                            Spacer()

                            if article.markedAsRead {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        Button {
                            state.markAsRead(articleId: article.id, value: !article.markedAsRead) {
                                self.refreshArticles()
                            }
                        } label: {
                            if article.markedAsRead {
                                Text("Mark as Unread")
                            } else {
                                Text("Mark as Read")
                            }
                        }
                    }))
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(feed.title)
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
