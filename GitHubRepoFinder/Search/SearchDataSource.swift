//
//  SearchDataSource.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/23/22.
//

import AsyncDisplayKit

class SearchDataSource: NSObject, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        // TODO: grab repo object here
        return {
            let node = RepoCellNode()
            node.backgroundColor = .blue
            return node
        }
    }
}
