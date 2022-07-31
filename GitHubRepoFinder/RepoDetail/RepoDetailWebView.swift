//
//  RepoDetailWebView.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/31/22.
//

import AsyncDisplayKit
import WebKit

class RepoDetailWebView: ASDisplayNode {
    init(urlRequest: URLRequest) {
        super.init()
        setViewBlock {
            let webView = WKWebView()
            webView.load(urlRequest)
            return webView
        }
    }
}
