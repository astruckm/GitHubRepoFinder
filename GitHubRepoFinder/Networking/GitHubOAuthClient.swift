//
//  GitHubOAuthClient.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/24/22.
//

import Foundation

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
            let dataResult = self.handleDataTaskErrors(data: data, response: response, error: error)
            switch dataResult {
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
