//
//  SearchDisplayNode.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/21/22.
//

import AsyncDisplayKit
import SwiftUI

class SearchDisplayNode: ASDisplayNode {
    let textNode = SearchTextNode(height: 50) { text in
        print("didEnter text: \(text) in search bar")
    }
    let tableNode = ASTableNode(style: .plain)
    let dataSource = SearchDataSource()
    
    override init() {
        super.init()
        self.addSubnode(textNode)
        self.addSubnode(tableNode)
        
        tableNode.dataSource = dataSource
        tableNode.delegate = self
        
        tableNode.backgroundColor = .blue
        
        textNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 32)
        tableNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 32 - 44)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0), child: textNode)
        let tableInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: tableNode)
        
        let containingVSpec = ASStackLayoutSpec(direction: .vertical,
                                                 spacing: 8,
                                                 justifyContent: .start,
                                                 alignItems: .center,
                                                 children: [textSpec, tableInsetSpec])
        return containingVSpec
    }
}

extension SearchDisplayNode: ASEditableTextNodeDelegate {
    
}

extension SearchDisplayNode: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: UIScreen.main.bounds.width, height: 100)
        let max = CGSize(width: UIScreen.main.bounds.width, height: 200)
        return ASSizeRange(min: min, max: max)
    }
    
    // TODO: use to make sticky header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }

}

// MARK: Canvas preview
struct SearchDisplayNodeSwiftUI: UIViewRepresentable {
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIViewType {
        let view = SearchDisplayNode().view
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct SearchDisplayNodeSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchDisplayNodeSwiftUI()
                .preferredColorScheme(.light)
            SearchDisplayNodeSwiftUI()
                .preferredColorScheme(.dark)
        }
    }
}
