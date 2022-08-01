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
    var readMeFullHTML: String?
    var imageURL: URL?
    
    var readMeUrlRequest: URLRequest? {
        guard let html = readMeFullHTML, let url = URL(string: html) else { return nil }
        return URLRequest(url: url)
    }
    
    init(title: String, description: String, language: String, numStars: Int, repoFullHTML: String? = nil, imageURL: URL? = nil) {
        self.title = title
        self.description = description
        self.language = language
        self.numStars = numStars
        self.readMeFullHTML = repoFullHTML
        self.imageURL = imageURL
    }
}

class SearchViewModel {
    let client = GitHubApiClient()
    let oauthClient = GitHubOAuthClient()
    var user: User?
    var repos: SearchReposResponse?
    var reposViewData: [RepoCellViewData] = []
    var updateAllRepos: (([RepoCellViewData]) -> Void)?
    var updateRepo: ((IndexPath, RepoCellViewData) -> Void)?
    
    
    let reposViewDataUpdateQueue = DispatchQueue(label: "com.astruckmarcell.GitHubRepoFinder.reposViewDataUpdateQueue")

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
                for (index, item) in reposSearchResponse.items.enumerated() {
                    self.getReadMeImageURL(repoItem: item, atIndex: index)
                }
            case .failure(let error):
                print("error getting repos: ", error)
            }
        }
    }
    
    func getReadMeImageURL(repoItem item: Item, atIndex index: Int) {
        let fullName = item.fullName
        client.getReadMeImage(fullRepoName: fullName, accessToken: oauthClient.accessToken) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let repoContents):
                self.reposViewDataUpdateQueue.async {
                    guard index < self.reposViewData.count else { return }
                    let indexPath = IndexPath(row: index, section: 0)
                    let newViewData = self.reposViewData[index]
                    newViewData.readMeFullHTML = repoContents.html
                    newViewData.imageURL = repoContents.imageURL
                    
                    self.reposViewData[index] = newViewData
                    self.updateRepo?(indexPath, newViewData)
                }
            case .failure(let error):
                print("error fetching image: \(error)")
            }
        }
    }
    
    func populateViewData(fromSearchReposResponse response: SearchReposResponse) {
        // TODO: make description be only first 1000 characters or whatever, make sure that language property corresponds to most used one. Check if stargazersCount is every nil
        reposViewData = response.items.map { RepoCellViewData(title: $0.name, description: $0.description ?? "", language: $0.language ?? "", numStars: $0.stargazersCount ?? 0) }
        updateAllRepos?(reposViewData)
    }

}
