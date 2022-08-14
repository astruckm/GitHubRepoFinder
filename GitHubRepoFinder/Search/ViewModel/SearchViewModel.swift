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
    var reposViewData: [RepoCellViewData] = []
    var updateAllRepos: (([RepoCellViewData]) -> Void)?
    var updateRepo: ((IndexPath, RepoCellViewData) -> Void)?
    let dataController: DataController
    let reposViewDataUpdateQueue = DispatchQueue(label: "com.astruckmarcell.GitHubRepoFinder.reposViewDataUpdateQueue")
    
    init() {
        dataController = DataController {
        }
    }

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
        reposViewData = response.items.map { RepoCellViewData(title: $0.name, description: $0.description ?? "", language: $0.language ?? "", numStars: $0.stargazersCount ?? 0) }
        saveReposViewData(reposViewData)
        updateAllRepos?(reposViewData)
    }

    func saveReposViewData(_ viewData: [RepoCellViewData]) {
        dataController.saveNewRepos(viewData)
    }

    func loadReposViewData() {
        if let savedRepos = dataController.loadRepos() as? [SavedRepo] {
            reposViewData = savedRepos.compactMap { convertSavedRepoToViewData(_: $0) }
            updateAllRepos?(reposViewData)
        }
    }
    
    func convertSavedRepoToViewData(_ savedRepo: SavedRepo) -> RepoCellViewData? {
        guard let title = savedRepo.title, !title.isEmpty else { return nil }
        guard let repoDesc = savedRepo.repoDescription, !repoDesc.isEmpty  else { return nil }
        let numStars = Int(savedRepo.numStars)
        guard numStars >= 0 else { return nil }
        let language = savedRepo.language ?? ""

        return RepoCellViewData(title: title,
                                description: repoDesc,
                                language: language,
                                numStars: numStars,
                                readMeFullHTML: savedRepo.readMe,
                                imageURL: savedRepo.imageURL)
    }
}

