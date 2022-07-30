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
    
    init(height: CGFloat) {
        super.init()
        setViewBlock {
            let searchView: UISearchBar = .init()
            searchView.placeholder = "Search GitHub repos"
            searchView.backgroundImage = nil
            searchView.backgroundColor = .clear
            searchView.searchBarStyle = .minimal
            searchView.delegate = self
            return searchView
        }
        self.style.height = ASDimension(unit: .points, value: height)
        self.backgroundColor = .systemBackground
    }
                
}

extension SearchTextNode: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        didEndEditing?(text)
        searchBar.resignFirstResponder()
    }
}
