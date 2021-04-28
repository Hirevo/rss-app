
import SwiftUI

struct ArticleScreen: View {
    var article: Article

    var body: some View {
        if let htmlContent = article.htmlContent {
            HTMLWebView(html: htmlContent).navigationTitle(article.title)
        } else if let url = article.url {
            WebView(url: url).navigationTitle(article.title)
        }
    }
}

//struct ArticleScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        ArticleScreen()
//    }
//}
