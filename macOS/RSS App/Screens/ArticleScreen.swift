
import SwiftUI

struct ArticleScreen: View {
    var article: Article

    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            if let htmlContent = article.htmlContent {
                HTMLWebView(html: htmlContent).navigationTitle(article.title)
            } else if let url = article.url {
                WebView(url: url).navigationTitle(article.title)
            }
        }
        .onAppear {
            state.markAsRead(articleId: article.id)
        }
    }
}

//struct ArticleScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        ArticleScreen()
//    }
//}
