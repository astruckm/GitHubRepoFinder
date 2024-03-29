//
//  SearchDisplayNode.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/21/22.
//

import AsyncDisplayKit
import SwiftUI

class SearchDisplayNode: ASDisplayNode {
    let textNode: SearchTextNode
    let tableNode = ASTableNode(style: .plain)
    let dataSource = SearchDataSource()
    var textCallback: ((String) -> Void)?
    var rowSelectionAction: ((IndexPath) -> Void)?
    
    override init() {
        self.textNode = SearchTextNode(height: 50)
        super.init()
        self.addSubnode(textNode)
        self.addSubnode(tableNode)
        self.textNode.didEndEditing = { [weak self] text in
            self?.textCallback?(text)
        }
        
        tableNode.dataSource = dataSource
        tableNode.delegate = self
        
        textNode.style.preferredSize = CGSize(width: 1000, height: 32)
        tableNode.style.preferredSize = CGSize(width: 1000, height: UIScreen.main.bounds.height - 32 - 44)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textSpec = ASInsetLayoutSpec(insets: .zero, child: textNode)
        let tableInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: tableNode)
        
        let containingVSpec = ASStackLayoutSpec(direction: .vertical,
                                                 spacing: 8,
                                                 justifyContent: .start,
                                                 alignItems: .center,
                                                 children: [textSpec, tableInsetSpec])
        return containingVSpec
    }
}

extension SearchDisplayNode: ASTableDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        rowSelectionAction?(indexPath)
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
