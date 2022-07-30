//
//  GitHubApiTypes.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/28/22.
//

import Foundation

enum GitHubRequestType {
    case codeExchange
    case getRepos
    case getUser
    case getReadMe
    
    var httpMethod: HTTPMethod {
        switch self {
        case .codeExchange: return .post
        case .getRepos, .getUser, .getReadMe: return .get
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
