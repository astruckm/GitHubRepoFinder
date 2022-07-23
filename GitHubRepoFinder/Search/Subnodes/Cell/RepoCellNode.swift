//
//  RepoCellNode.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/23/22.
//

import AsyncDisplayKit
import SwiftUI

class RepoCellNode: ASCellNode {
    // TODO: use ASNetworkImageNode
    let firstImage = ASNetworkImageNode()
    let label = ASTextNode()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        configure()
        
        firstImage.image = UIImage(systemName: "photo.fill")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imagePadding = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 0), child: firstImage)
        
        
        let hStack = ASStackLayoutSpec(direction: .horizontal,
                                       spacing: 0,
                                       justifyContent: .start,
                                       alignItems: .start,
                                       children: [])
        return imagePadding
    }
    
    func configure() {
        firstImage.backgroundColor = .red
        firstImage.style.preferredSize = CGSize(width: 25, height: 25)
        label.attributedText = NSAttributedString(string: "Test label")
    }
}


struct RepoCellNodeSwiftUI: UIViewRepresentable {
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        let cell = RepoCellNode().view
        return cell
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct RepoCellNodeSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        RepoCellNodeSwiftUI()
    }
}
