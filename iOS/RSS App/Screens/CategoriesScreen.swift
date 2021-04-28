
import SwiftUI

private struct CategoryFeeds {
    var name: String
    var feeds: [Feed]
}

struct CategoriesScreen: View {
    @State private var categories: [CategoryFeeds] = []

    @EnvironmentObject private var state: AppState

    @State private var addingFeed = false

    var body: some View {
        NavigationView {
            List {
                if categories.isEmpty {
                    HStack {
                        Spacer()
                        Text("No categories").foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ForEach(categories, id: \.name) { category in
                        NavigationLink(destination: CategoryFeedsScreen(category: category.name, feeds: category.feeds)) {
                            Text(category.name)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Categories")
        }
        .onAppear {
            self.refreshCategories()
        }
    }

    func refreshCategories() {
        state.categories { maybeCategories in
            if case .some(let categories) = maybeCategories {
                self.categories = categories.map { (name, feeds) in CategoryFeeds(name: name, feeds: feeds) }
            }
        }
    }
}

//struct CategoriesScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesScreen()
//    }
//}
