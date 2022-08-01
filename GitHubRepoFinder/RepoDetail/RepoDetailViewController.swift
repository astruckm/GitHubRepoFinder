//
//  RepoDetailViewController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/31/22.
//

import AsyncDisplayKit
import WebKit

class RepoDetailViewController: ASDKViewController<ASDisplayNode> {
    let readMeWebView: RepoDetailWebView

    init(readMe: String) {
        readMeWebView = RepoDetailWebView(html: readMe)
        
        let baseNode = ASDisplayNode()
        baseNode.addSubnode(readMeWebView)
        super.init(node: baseNode)
        
        self.node.layoutSpecBlock = { node, constrainedSize in
            return ASInsetLayoutSpec(insets: .zero, child: self.readMeWebView)
        }
    }
    
    required init?(coder: NSCoder) {
        readMeWebView = RepoDetailWebView(html: "")
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = .systemBackground
    }
}
