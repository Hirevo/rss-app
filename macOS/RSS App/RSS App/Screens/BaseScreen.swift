
import SwiftUI

enum AppLocation {
    case feeds
    case articles(Feed)
    case article(Article)
    case categories
    case categoryFeeds(String, [Feed])
    case settings
}

class AppLocationManager: ObservableObject {
    @Published private(set) var location: [AppLocation] = []

    var current: AppLocation? {
        self.location.last
    }

    func push(_ location: AppLocation) {
        self.location.append(location)
    }

    func pop() {
        let _ = self.location.popLast()
    }

    func resetTo(_ location: AppLocation) {
        self.location = [location]
    }
}

struct BaseScreen: View {
    @ObservedObject private var location = AppLocationManager()

    var body: some View {
        VStack(spacing: 0) {
            Navbar(canGoBack: location.current != nil, onBack: goBack, label: { Text(label()).bold().font(.title) })

            Rectangle().frame(height: 2).background(FG_COLOR)

            VStack(spacing: 0) {
                switch location.current {
                case .feeds:
                    FeedsScreen()
                        .environmentObject(location)
                case .articles(let feed):
                    ArticlesScreen(feed: feed)
                        .environmentObject(location)
                case .article(let article):
                    ArticleScreen(article: article)
                        .environmentObject(location)
                case .categories:
                    CategoriesScreen()
                        .environmentObject(location)
                case .categoryFeeds(let category, let feeds):
                    CategoryFeedsScreen(category: category, feeds: feeds)
                        .environmentObject(location)
                case .settings:
                    SettingsScreen()
                        .environmentObject(location)
                default:
                    HomeScreen()
                        .environmentObject(location)
                }

                Spacer()
            }
        }
    }

    func goBack() {
        location.pop()
    }

    func label() -> String {
        switch location.current {
        case .feeds:
            return "Feeds"
        case .articles(let feed):
            return feed.title
        case .article(let article):
            return article.title
        case .categories:
            return "Categories"
        case .categoryFeeds(let category, _):
            return category
        case .settings:
            return "Settings"
        default:
            return "RSS App"
        }
    }

    func navigate(_ location: AppLocation) {
        self.location.push(location)
    }
}

//struct BaseScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        BaseScreen()
//    }
//}
