//
//  RepoDetailWebView.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/31/22.
//

import AsyncDisplayKit
import WebKit

class RepoDetailWebView: ASDisplayNode {
    init(html: String?) {
        super.init()

        guard let html = html else { return }

        setViewBlock {
            let webView = WKWebView()
            webView.loadHTMLString(html, baseURL: nil)
            return webView
        }
        self.backgroundColor = .green
    }
}
