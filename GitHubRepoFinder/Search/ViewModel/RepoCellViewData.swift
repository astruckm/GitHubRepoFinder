//
//  RepoCellViewData.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 8/13/22.
//

import Foundation

class RepoCellViewData {
    let title: String
    let description: String
    let language: String
    let numStars: Int
    var readMeFullHTML: String?
    var imageURL: URL?
        
    init(title: String, description: String, language: String, numStars: Int, readMeFullHTML: String? = nil, imageURL: URL? = nil) {
        self.title = title
        self.description = description
        self.language = language
        self.numStars = numStars
        self.readMeFullHTML = readMeFullHTML
        self.imageURL = imageURL
    }
}
