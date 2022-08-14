//
//  String+Extensions.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/28/22.
//

import Foundation

extension String {
    func gitHubReadMeFirstImageURL(repoFullName fullName: String) -> URL? {
        if let range = self.range(of: "(src=\"|https://)(.*)(.jpg|.jpe|.png|.gif)", options: .regularExpression) {
            let imageURLStr = self[range.lowerBound...range.upperBound]
                .replacingOccurrences(of: "src=\"", with: "")
                .replacingOccurrences(of: "\"", with: "")
            let fullURL: URL?
            if imageURLStr.contains("https://") {
                fullURL = URL(string: imageURLStr)
            } else if imageURLStr.contains("http://") {
                return nil
            } else {
                let fullURLStr = "https://raw.githubusercontent.com/" + fullName + "/master/" + imageURLStr
                fullURL = URL(string: fullURLStr)
            }
            guard let url = fullURL else { return nil }
            return url
        }
        return nil
    }
}


