//
//  RepoDetailViewController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/31/22.
//

import AsyncDisplayKit
import WebKit

class RepoDetailViewController: ASDKViewController<ASDisplayNode> {
    let textNode = ASTextNode()

    init(readMe: String) {
//        if let request = request {
//            let baseNode = RepoDetailWebView(urlRequest: request)
//            super.init(node: baseNode)
//        } else {
//            super.init(node: ASDisplayNode())
//        }
        let baseNode = ASDisplayNode()
        textNode.attributedText = NSAttributedString(string: readMe)
        baseNode.addSubnode(textNode)
        super.init(node: baseNode)
        
        textNode.style.preferredSize = CGSize(width: 200, height: 100)
        
        self.node.layoutSpecBlock = { node, constrainedSize in
            let textNodespec = ASInsetLayoutSpec(insets: .zero, child: self.textNode)
            return ASInsetLayoutSpec(insets: .zero, child: textNodespec)
        }

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = .systemBackground
    }
}
