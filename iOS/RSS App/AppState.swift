
import Foundation

enum NetworkError: Error {
    case badURL
    case badData
}

struct ProfileData: Decodable {
//    var userId: String
    var email: String
    var name: String
    var usingGoogle: Bool
}

struct TokenData: Decodable {
    var token: String
}

class AppState: ObservableObject {
    @Published private(set) var tokenData: TokenData? = nil
    @Published private(set) var profileData: ProfileData? = nil

    @Published private(set) var initialized = false

    static let endpoint = "https://rss.polomack.eu"
    
    var loggedIn: Bool {
        return self.profileData != nil
    }

    func login(token: String, onCompletion: @escaping () -> Void = {}) {
        self.refreshProfileData(tokenData: TokenData(token: token), onCompletion: onCompletion)
    }

    private func refreshProfileData(tokenData: TokenData, onCompletion: @escaping () -> Void = {}) {
        DispatchQueue.main.schedule {
            self.profileData = nil
            self.tokenData = nil
        }

        guard let url = URL(string: "\(Self.endpoint)/api/v1/account/me") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }
            
            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let profileData = try? decoder.decode(ProfileData.self, from: data) else {
                print("failed to decode")
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }
            
            DispatchQueue.main.schedule {
                self.profileData = profileData
                self.tokenData = tokenData
                onCompletion()
            }
        }
        
        dataTask.resume()
    }
    
    func login(email: String, password: String, onCompletion: @escaping () -> Void = {}) {
        DispatchQueue.main.schedule {
            self.profileData = nil
            self.tokenData = nil
        }

        guard let url = URL(string: "\(Self.endpoint)/auth/login") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "email": email,
            "password": password,
        ])
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }
            
            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let tokenData = try? decoder.decode(TokenData.self, from: data) else {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            self.refreshProfileData(tokenData: tokenData, onCompletion: onCompletion)
        }
        
        dataTask.resume()
    }

    func register(email: String, name: String, password: String, onCompletion: @escaping () -> Void = {}) {
        DispatchQueue.main.schedule {
            self.profileData = nil
            self.tokenData = nil
        }

        guard let url = URL(string: "\(Self.endpoint)/auth/register") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "email": email,
            "name": name,
            "password": password,
        ])

        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    self.profileData = nil
                    self.tokenData = nil
                    onCompletion()
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    self.profileData = nil
                    self.tokenData = nil
                    onCompletion()
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let tokenData = try? decoder.decode(TokenData.self, from: data) else {
                DispatchQueue.main.schedule {
                    self.profileData = nil
                    self.tokenData = nil
                    onCompletion()
                }
                return
            }

            self.refreshProfileData(tokenData: tokenData, onCompletion: onCompletion)
        }

        dataTask.resume()
    }

    func logout(onCompletion: @escaping () -> Void = {}) {
        guard let tokenData = self.tokenData, let url = URL(string: "\(Self.endpoint)/auth/logout") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            guard let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    DispatchQueue.main.schedule {
                        onCompletion()
                    }
                }
                return
            }
            
            if response.statusCode == 200 {
                DispatchQueue.main.schedule {
                    self.profileData = nil
                    onCompletion()
                }
                return
            }
            
            DispatchQueue.main.schedule {
                onCompletion()
            }
        }
        
        dataTask.resume()
    }

    func feeds(onCompletion: @escaping (Optional<[Feed]>) -> Void = { _ in }) {
        guard let tokenData = self.tokenData, let url = URL(string: "\(Self.endpoint)/api/v1/feeds") else {
            DispatchQueue.main.schedule {
                onCompletion(.none)
            }
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let feeds = try? decoder.decode([Feed].self, from: data) else {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            onCompletion(.some(feeds))
        }

        dataTask.resume()
    }

    func articles(feedId: String, onCompletion: @escaping (Optional<[Article]>) -> Void = { _ in }) {
        guard let feedId = feedId.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            DispatchQueue.main.schedule {
                onCompletion(.none)
            }
            return
        }

        guard let tokenData = self.tokenData, let url = URL(string: "\(Self.endpoint)/api/v1/articles/\(feedId)") else {
            DispatchQueue.main.schedule {
                onCompletion(.none)
            }
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let feeds = try? decoder.decode([Article].self, from: data) else {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            onCompletion(.some(feeds))
        }

        dataTask.resume()
    }

    func addFeed(feedUrl: String, onCompletion: @escaping () -> Void = {}) {
        guard let tokenData = self.tokenData, let url = URL(string: "\(Self.endpoint)/api/v1/feeds") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "url": feedUrl,
        ])

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            onCompletion()
        }

        dataTask.resume()
    }

    func deleteFeed(feedId: String, onCompletion: @escaping () -> Void = {}) {
        guard let feedId = feedId.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }

        guard let tokenData = self.tokenData, let url = URL(string: "\(Self.endpoint)/api/v1/feed/\(feedId)") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            onCompletion()
        }

        dataTask.resume()
    }

    func categories(onCompletion: @escaping (Optional<[String: [Feed]]>) -> Void = { _ in }) {
        guard let tokenData = self.tokenData, let url = URL(string: "\(Self.endpoint)/api/v1/categories") else {
            DispatchQueue.main.schedule {
                onCompletion(.none)
            }
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let categories = try? decoder.decode([String: [Feed]].self, from: data) else {
                DispatchQueue.main.schedule {
                    onCompletion(.none)
                }
                return
            }

            onCompletion(.some(categories))
        }

        dataTask.resume()
    }

    func markAsRead(articleId: String, value: Bool = true, onCompletion: @escaping () -> Void = {}) {
        guard let articleId = articleId.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }

        guard let tokenData = self.tokenData, let url = URL(string: "\(Self.endpoint)/api/v1/article/\(articleId)") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(tokenData.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "read": value,
        ])

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    onCompletion()
                }
                return
            }

            onCompletion()
        }

        dataTask.resume()
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
