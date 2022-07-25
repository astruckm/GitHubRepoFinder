//
//  SearchViewModel.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/20/22.
//

import Foundation

class SearchViewModel {
    let client = GitHubApiClient()
    let oauthClient = GitHubOAuthClient()
    var user: User?
    var repos: SearchReposResponse?

    func handleGitHubAuthCallback(_ url: URL?, error: Error?) {
        if let error = error {
            print("error with GitHub Auth callback: \(error), \(error.localizedDescription)")
        }
        guard let callbackURL = url,
              let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
              let code = queryItems.first(where: { $0.name == "code" })?.value
        else {
            print("Could not get auth code from callback URL")
            return
        }
        getAccessToken(with: code)
    }
    
    func getAccessToken(with code: String) {
        oauthClient.loadTokens(with: code) { [weak self] result in
            switch result {
            case .success(_):
                self?.getUser()
            case .failure(let err):
                print("failure with error: ", err)
            }
        }
    }
    
    func getUser() {
        guard let getUserURL = URL(string: client.userURL) else { return }
        client.getUser(fromURL: getUserURL, accessToken: oauthClient.accessToken) { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                print("User is: ", user)
            case .failure(let error):
                print("error getting user: ", error)
            }
        }
    }
    
    func getRepos(with searchQuery: String) {
        guard let getReposURL = client.makeFullSearchReposURL(from: searchQuery) else { return }
        client.getRepos(fromURL: getReposURL, accessToken: oauthClient.accessToken) { [weak self] result in
            switch result {
            case .success(let repos):
                self?.repos = repos
                print("Repos total count: ", repos.totalCount)
                print("Repos num Items: ", repos.items.count)
                for item in repos.items {
                    print("fullName: ", item.fullName)
                    print("Name: ", item.name)
                    print("Description: ", item.description)
                    print("Language: ", item.language)
                    print("Stargazers count: ", item.stargazersCount)
                    if item.fullName == "facebook/jest" {
                        self?.getReadMeImage(repoFullName: item.fullName)
                    }
                }
            case .failure(let error):
                print("error getting repos: ", error)
            }
        }
    }
    
    func getReadMeImage(repoFullName fullName: String) {
        client.getReadMeImage(fullRepoName: fullName, accessToken: oauthClient.accessToken) { result in
            switch result {
            case .success(let img): break
            case .failure(let error):
                print("error fetching image: \(error)")
            }
        }
    }
    

}
