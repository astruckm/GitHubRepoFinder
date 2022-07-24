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

enum GitHubReposSortOption {
    case stars(SortOrder = .descending)
    case forks(SortOrder = .descending)
    case helpWantedIssues(SortOrder = .descending)
    case updated(SortOrder = .descending)
    
    enum SortOrder: String {
        case descending = "desc"
        case ascending = "asc"
    }
    
    var queryValue: String {
        switch self {
        case .stars: return "stars"
        case .forks: return "forks"
        case .helpWantedIssues: return "help-wanted-issues"
        case .updated: return "updated"
        }
    }
    
    var order: String {
        switch self {
        case .stars(let sortOrder): return sortOrder.rawValue
        case .forks(let sortOrder): return sortOrder.rawValue
        case .helpWantedIssues(let sortOrder): return sortOrder.rawValue
        case .updated(let sortOrder): return sortOrder.rawValue
        }
    }
}


class GitHubApiClient: HttpClientHandler {
    // MARK: URLs
    let userURL = URL(string: "https://api.github.com/user")
    let searchReposURLStr = "https://api.github.com/search/repositories"
    
    func makeFullSearchReposURL(from searchQuery: String,
                                sortOption: GitHubReposSortOption? = nil,
                                page: UInt = 1) -> URL? {
        guard var components = URLComponents(string: searchReposURLStr) else { return nil }
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "q", value: searchQuery))
        if let sortOption = sortOption {
            queryItems.append(URLQueryItem(name: "sort", value: sortOption.queryValue))
            queryItems.append(URLQueryItem(name: "order", value: sortOption.order))
        }
        queryItems.append(URLQueryItem(name: "per_page", value: "100"))
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        components.queryItems = queryItems
        return components.url
    }
    
    // MARK: Network calls
    func loadUser(fromURL url: URL, accessToken: String?, completion: @escaping ((Result<User, Error>) -> Void)) {
        var request = URLRequest(url: url)
        request.httpMethod = GitHubRequestType.getUser.httpMethod.rawValue
        if let accessToken = accessToken {
            request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            let dataResult = self.handleDataTaskErrors(data: data, response: response, error: error)
            switch dataResult {
            case .success(let data):
                let userResult = self.processUser(data: data)
                completion(userResult)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func loadRepos(fromURL url: URL, accessToken: String? = nil, completion: @escaping ((Result<SearchReposResponse, Error>) -> Void)) {
        var request = URLRequest(url: url)
        request.httpMethod = GitHubRequestType.getRepos.httpMethod.rawValue
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        if let accessToken = accessToken {
            request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            let dataResult = self.handleDataTaskErrors(data: data, response: response, error: error)
            switch dataResult {
            case .success(let data):
                let reposResult = self.processRepos(data: data)
                completion(reposResult)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    func processUser(data: Data) -> Result<User, Error> {
        if let user = try? JSONDecoder().decode(User.self, from: data) {
            return .success(user)
        } else {
            let errorStr = String(String(data: data, encoding: .utf8)?.prefix(1000) ?? "")
            return .failure(NetworkingError.dataDecodingFailure(errorStr))
        }
    }
    
    func processRepos(data: Data) -> Result<SearchReposResponse, Error> {
        if let repos = try? JSONDecoder().decode(SearchReposResponse.self, from: data) {
            return .success(repos)
        } else {
            let errorStr = String(String(data: data, encoding: .utf8)?.prefix(1000) ?? "")
            return .failure(NetworkingError.dataDecodingFailure(errorStr))
        }
    }
}
