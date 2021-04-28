
struct Feed: Decodable, Identifiable {
    var id: String
    var title: String
    var description: String?
    var feedUrl: String?
    var homepageUrl: String?
}

struct Article: Decodable, Identifiable {
//    var markedAsRead: Bool
    var id: String
    var feedId: String
    var title: String
    var url: String?
    var htmlContent: String?
}

struct Category: Decodable, Identifiable {
    var id: String
}
