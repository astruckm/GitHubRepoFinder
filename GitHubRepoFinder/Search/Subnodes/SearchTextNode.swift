//
//  SearchTextNode.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/21/22.
//

import AsyncDisplayKit

class SearchTextNode: ASDisplayNode {
    var searchBarRef: UISearchBar? {
        return self.view as? UISearchBar
    }
    var didEndEditing: ((String) -> Void)?
    
    init(height: CGFloat, didEndEditing: @escaping ((String) -> Void)) {
        super.init()
        setViewBlock {
            let searchView: UISearchBar = .init()
            searchView.placeholder = "Search GitHub repos"
            searchView.backgroundImage = nil
            searchView.backgroundColor = .clear
            searchView.searchBarStyle = .minimal
            return searchView
        }
        self.style.height = ASDimension(unit: .points, value: height)
        self.backgroundColor = .systemBackground
    }
                
//    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        
//        
//        return ASInsetLayoutSpec(insets: .zero, child: <#T##ASLayoutElement#>)
//    }
}

extension SearchTextNode: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        didEndEditing?(text)
    }
}
