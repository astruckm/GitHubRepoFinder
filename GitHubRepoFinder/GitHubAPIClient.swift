//
//  GitHubAPIClient.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/9/22.
//

import Foundation

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
