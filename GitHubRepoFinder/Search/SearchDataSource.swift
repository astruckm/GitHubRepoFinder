//
//  SearchDataSource.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/23/22.
//

import AsyncDisplayKit

class SearchDataSource: NSObject, ASTableDataSource {
    var viewData: [RepoCellViewData] = []
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewData.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        guard indexPath.row < viewData.count else { return RepoCellNode() }
        let cellViewData = viewData[indexPath.row]

        let cell = RepoCellNode()
        cell.configure(with: cellViewData)
        return cell
    }
    
}
