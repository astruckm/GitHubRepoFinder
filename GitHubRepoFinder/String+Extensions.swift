//
//  String+Extensions.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/28/22.
//

import Foundation

extension String {
    // TODO: unit test
    func gitHubReadMeFirstImageURL(repoFullName fullName: String) -> URL? {
        if let range = self.range(of: "(src=\"|https://)(.*)(.jpg|.jpe|.png|.gif)", options: .regularExpression) {
            let imageURLStr = self[range.lowerBound...range.upperBound]
                .replacingOccurrences(of: "src=\"", with: "")
                .replacingOccurrences(of: "\"", with: "")
            let fullURL: URL?
            if imageURLStr.contains("https://") {
                fullURL = URL(string: imageURLStr)
            } else {
                let fullURLStr = "https://raw.githubusercontent.com/" + fullName + "/main/" + imageURLStr
                fullURL = URL(string: fullURLStr)
            }
            guard let url = fullURL else { return nil }
            return url
        }
        return nil

    }
}
