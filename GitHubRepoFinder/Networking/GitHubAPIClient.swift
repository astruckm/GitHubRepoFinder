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
    case signIn
    case codeExchange
    case getRepos
    case getUser

    var httpMethod: HTTPMethod {
        switch self {
        case .codeExchange: return .post
        case .getRepos, .getUser, .signIn: return .get
        }
    }
    
}

class GitHubOAuthClient: HttpClientHandler {
    var accessToken: String?
    var refreshToken: String?

    var authURL: URL? {
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
    
    func loadTokens(with code: String, completion: @escaping ((Result<String, Error>) -> Void)) {
        guard let url = generateAccessTokenURL(with: code) else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }
        let requestType = GitHubRequestType.codeExchange
        var request = URLRequest(url: url)
        request.httpMethod = requestType.httpMethod.rawValue
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                completion(.failure(NetworkingError.objectReleasedEarly("GitHubOAuthClient released before loadTokens completion")))
                return
            }
            let data = self.handleDataTaskErrors(data: data, response: response, error: error)
            switch data {
            case .success(let data):
                let tokenResponse = self.unwrapTokenResponse(data)
                completion(.success(tokenResponse ?? ""))
            case .failure(let err):
                completion(.failure(err))
            }
        }
        task.resume()
    }
    
    @discardableResult
    func unwrapTokenResponse(_ data: Data) -> String? {
        if let responseStr = String(data: data, encoding: .utf8) {
            let components = responseStr.components(separatedBy: "&")
            for component in components {
                let componentParts = component.components(separatedBy: "=")
                guard let key = componentParts.first, let value = componentParts.last else { continue }
                if key == "access_token" {
                    self.accessToken = value
                } else if key == "refresh_token" {
                    self.refreshToken = value
                }
            }
            return responseStr
        } else {
            return nil
        }

    }
    
}

class GitHubApiClient: HttpClientHandler {
    // MARK: URLs
    let userURL = URL(string: "https://api.github.com/user")

    // MARK: Network calls
    func loadUser(fromURL url: URL, accessToken: String?, completion: @escaping ((Result<User, Error>) -> Void)) {
        var request = URLRequest(url: url)
        request.httpMethod = GitHubRequestType.getUser.httpMethod.rawValue
        if let accessToken = accessToken {
            request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return }

            do {
                if let responseType = try? JSONDecoder().decode(User.self, from: data) {
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
