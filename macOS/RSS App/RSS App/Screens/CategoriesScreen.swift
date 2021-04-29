
import SwiftUI
import WrappingHStack

private struct CategoryFeeds {
    var name: String
    var feeds: [Feed]
}

struct CategoriesScreen: View {
    @State private var categories: [CategoryFeeds] = []

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var location: AppLocationManager

    var body: some View {
        List {
            if categories.isEmpty {
                Text("No categories").bold().font(.title2).foregroundColor(.secondary).inExpandingRectangle()
            } else {
                ForEach(categories, id: \.name) { category in
                    Button {
                        location.push(.categoryFeeds(category.name, category.feeds))
                    } label: {
                        Text(category.name).lineLimit(1)
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
            self.refreshCategories()
        }
    }

    func refreshCategories() {
        state.categories { maybeCategories in
            if case .some(let categories) = maybeCategories {
                self.categories = categories.map {
                    return CategoryFeeds(name: $0, feeds: $1)
                }
            }
        }
    }
}

//struct CategoriesScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedsScreen()
//    }
//}
