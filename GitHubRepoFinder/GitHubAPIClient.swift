//
//  GitHubAPIClient.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/9/22.
//

import Foundation

class GitHubAPIClient {
    func generateAuthURL() -> URL? {
//        let gitHubClientStr = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT") as? String
        let gitHubClientIdStr = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_ID") as? String
        let scope = "read:user,public_repo"
        let state = UUID().uuidString
        let gitHubAuthUrl = "https://github.com/login/oauth/authorize"
        
        var urlComponents = URLComponents(string: gitHubAuthUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: gitHubClientIdStr),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "state", value: state)
        ]
        return urlComponents?.url
    }
}
