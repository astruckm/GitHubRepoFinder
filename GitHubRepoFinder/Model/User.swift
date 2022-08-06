//
//  User.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/10/22.
//

import Foundation

struct User: Codable {
    let login: String
    let name: String?
    let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case login, name
        case htmlURL = "html_url"
    }
}


