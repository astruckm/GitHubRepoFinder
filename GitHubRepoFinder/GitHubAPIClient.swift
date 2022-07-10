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
    
    
    func generateAuthURL() -> URL? {
        let gitHubClientIdStr = GitHubConstants.clientID
        let gitHubAuthUrl = "https://github.com/login/oauth/authorize"
        
        var urlComponents = URLComponents(string: gitHubAuthUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: gitHubClientIdStr)
        ]
        return urlComponents?.url
    }
}
