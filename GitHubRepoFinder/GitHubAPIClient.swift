//
//  GitHubAPIClient.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/9/22.
//

import Foundation

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
}

enum GitHubRequestType {
    case codeExchange(code: String)
    case getRepos
    case getUser
    case signIn

    var httpMethod: HTTPMethod {
        switch self {
        case .codeExchange(_): return .post
        case .getRepos, .getUser, .signIn: return  .get
        }
    }
}

class GitHubAPIClient {
    var accessToken: String?
    var refreshToken: String?
    
    let userURL = URL(string: "https://api.github.com/user")

    func generateAuthURL() -> URL? {
//        let gitHubClientIdStr = GitHubConstants.clientID
        let gitHubAuthUrl = "https://github.com/login/oauth/authorize"
        
        var urlComponents = URLComponents(string: gitHubAuthUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: GitHubConstants.clientID)
        ]
        return urlComponents?.url
    }
    
    func generateAccessTokenURL(with code: String) -> URL? {
        let url = "https://github.com/login/oauth/access_token"
        
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: GitHubConstants.clientID),
            URLQueryItem(name: "client_secret", value: GitHubConstants.clientSecret),
            URLQueryItem(name: "code", value: code)
        ]
        return urlComponents?.url
    }
    
    func load<T: Decodable>(fromURL url: URL, with requestType: GitHubRequestType, responseType: T.Type, completion: @escaping ((Result<T, Error>) -> Void)) {
        print("loading with url: ", url)
        var request = URLRequest(url: url)
        request.httpMethod = requestType.httpMethod.rawValue
        if let accessToken = self.accessToken {
            print("setting token")
            request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            print("data: \(data), response: \((response as? HTTPURLResponse)?.statusCode), error: \(error)")
            guard let data = data else { return }

            do {
                if T.self == String.self, let responseStr = String(data: data, encoding: .utf8) {
                    let components = responseStr.components(separatedBy: "&")
                    for component in components {
                        let componentParts = component.components(separatedBy: "=")
                        guard let key = componentParts.first, let value = componentParts.last else { continue }
                        if key == "access_token" {
                            self?.accessToken = value
                        } else if key == "refresh_token" {
                            self?.refreshToken = value
                        }
                    }
                    
                    completion(.success(responseStr as! T))
                    return
                }
                if let responseType = try? JSONDecoder().decode(T.self, from: data) {
                    completion(.success(responseType))
                } else {
                    let dataStr = String(data: data, encoding: .utf8)
                    print("dataStr wasn't decoded: ", dataStr)
                }
            } catch (let decodingErr) {
                print("decoding error: ", decodingErr)
                completion(.failure(decodingErr))
            }
        }
        task.resume()
    }
    
}
