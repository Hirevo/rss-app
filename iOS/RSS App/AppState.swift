
import Foundation
import AuthenticationServices

enum NetworkError: Error {
    case badURL
    case badData
}

struct ProfileData: Decodable {
    var email: String
}

class AppState: ObservableObject {
    @Published private(set) var email: String? = nil
    
    static let endpoint = "https://rss.polomack.eu"
    
    var loggedIn: Bool {
        return email != nil
    }
    
    func refreshSession(onCompletion: @escaping () -> Void = {}) {
        guard let url = URL(string: "\(Self.endpoint)/api/v1/account/me") else {
            DispatchQueue.main.schedule {
                self.email = nil
                onCompletion()
            }
            return
        }
        
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    self.email = nil
                    onCompletion()
                }
                return
            }
            
            if response.statusCode != 200 {
                DispatchQueue.main.schedule {
                    self.email = nil
                    onCompletion()
                }
                return
            }
            
            guard let profile = try? JSONDecoder().decode(ProfileData.self, from: data) else {
                DispatchQueue.main.schedule {
                    self.email = nil
                    onCompletion()
                }
                return
            }
            
            DispatchQueue.main.schedule {
                self.email = profile.email
                onCompletion()
            }
        }
        
        dataTask.resume()
    }
    
    func login(email: String, password: String, onCompletion: @escaping () -> Void = {}) {
        guard let url = URL(string: "\(Self.endpoint)/auth/login") else {
            DispatchQueue.main.schedule {
                self.email = nil
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
            
            guard let response = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.schedule {
                    self.email = nil
                    onCompletion()
                }
                return
            }
            
            if response.statusCode == 200 || response.statusCode == 302 || response.statusCode == 404 {
                DispatchQueue.main.schedule {
                    self.email = email
                    onCompletion()
                }
                return
            }
            
            DispatchQueue.main.schedule {
                self.email = nil
                onCompletion()
            }
        }
        
        dataTask.resume()
    }
    
    func logout(onCompletion: @escaping () -> Void = {}) {
        guard let url = URL(string: "\(Self.endpoint)/auth/logout") else {
            DispatchQueue.main.schedule {
                onCompletion()
            }
            return
        }
        
        var request = URLRequest(url: url)
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
            
            if response.statusCode == 200 || response.statusCode == 302 || response.statusCode == 404 {
                DispatchQueue.main.schedule {
                    self.email = nil
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
