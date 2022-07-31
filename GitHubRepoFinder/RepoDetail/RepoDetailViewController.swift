//
//  RepoDetailViewController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/31/22.
//

import AsyncDisplayKit
import WebKit

class RepoDetailViewController: ASDKViewController<ASDisplayNode> {
    let scrollNode = ASScrollNode()
    let textNode = ASTextNode()

    init(readMe: String) {
        let baseNode = ASDisplayNode()
        textNode.attributedText = NSAttributedString(string: readMe)
        baseNode.addSubnode(scrollNode)
        scrollNode.addSubnode(textNode)
        super.init(node: baseNode)
        
        scrollNode.style.flexGrow = 1.0
        scrollNode.automaticallyManagesContentSize = true
        
        self.scrollNode.layoutSpecBlock = { node, constrainedSize in
            let textNodeSpec = ASInsetLayoutSpec(insets: .zero, child: self.textNode)
            let scrollStackSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 0,
                                                    justifyContent: .start,
                                                    alignItems: .start,
                                                    children: [textNodeSpec])
            return scrollStackSpec

        }
        self.node.layoutSpecBlock = { node, constrainedSize in
            return ASInsetLayoutSpec(insets: .zero, child: self.scrollNode)
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
