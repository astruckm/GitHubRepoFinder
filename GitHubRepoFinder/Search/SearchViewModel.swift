//
//  SearchViewModel.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/20/22.
//

import Foundation

class RepoCellViewData {
    let title: String
    let description: String
    let language: String
    let numStars: Int
    var imageURL: URL?
    
    init(title: String, description: String, language: String, numStars: Int, imageURL: URL? = nil) {
        self.title = title
        self.description = description
        self.language = language
        self.numStars = numStars
        self.imageURL = imageURL
    }
}

class SearchViewModel {
    let client = GitHubApiClient()
    let oauthClient = GitHubOAuthClient()
    var user: User?
    var repos: SearchReposResponse?
    var reposViewData: [RepoCellViewData] = []
    var updateReposUI: (() -> Void)?

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
            guard let self = self else { return }
            switch result {
            case .success(let reposSearchResponse):
                self.repos = reposSearchResponse
                print("Repos total count: ", reposSearchResponse.totalCount)
                print("Repos num Items: ", reposSearchResponse.items.count)
                self.populateViewData(fromSearchReposResponse: reposSearchResponse)
                for item in reposSearchResponse.items {
//                    print("name: ", item.name)
//                    print("description: ", item.description)
//                    print("language: ", item.language)
//                    print("stars: ", item.stargazersCount)
                    self.getReadMeImageURL(repoItem: item)
                }
            case .failure(let error):
                print("error getting repos: ", error)
            }
        }
    }
    
    func getReadMeImageURL(repoItem item: Item) {
        let fullName = item.fullName
        client.getReadMeImage(fullRepoName: fullName, accessToken: oauthClient.accessToken) { result in
            switch result {
            case .success(let url):
                print("fetched image url: ", url)
                // TODO: assign to item
            case .failure(let error):
                print("error fetching image: \(error)")
            }
        }
    }
    
    func populateViewData(fromSearchReposResponse response: SearchReposResponse) {
        // TODO: make description be only first 1000 characters or whatever, make sure that language property corresponds to most used one. Check if stargazersCount is every nil
        self.reposViewData = response.items.map { RepoCellViewData(title: $0.name, description: $0.description ?? "", language: $0.language ?? "", numStars: $0.stargazersCount ?? 0) }
        self.updateReposUI?()
    }

}
