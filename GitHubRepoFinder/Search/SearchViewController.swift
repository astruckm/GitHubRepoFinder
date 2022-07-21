//
//  SearchViewController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/9/22.
//

import UIKit
import AsyncDisplayKit
import AuthenticationServices

class SearchViewController: ASDKViewController<ASDisplayNode> {
    let tableNode: ASTableNode
    
    let viewModel: SearchViewModel
    let client = GitHubApiClient()
    let oauthClient = GitHubOAuthClient()
    
    override init() {
        viewModel = SearchViewModel()

        let node = ASDisplayNode()
        let tableNode = ASTableNode(style: .plain)
        self.tableNode = tableNode
        super.init(node: node)
        
        tableNode.dataSource = self
        tableNode.delegate = self
    }
    
    required init?(coder: NSCoder) {
        viewModel = SearchViewModel()
        
        let tableNode = ASTableNode(style: .plain)
        self.tableNode = tableNode
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = .systemBackground
        node.addSubnode(tableNode)
        tableNode.frame = node.frame
        
        navigationController?.navigationBar.backgroundColor = .systemGray6
//        navigationController?.navigationBar.shadowImage = UIColor.darkGray.image(CGSize(width: view.frame.width, height: 1))
        self.navigationItem.title = "Repo Finder"
        let loginBarButton = UIBarButtonItem()
        loginBarButton.action = #selector(login)
        loginBarButton.target = self
        loginBarButton.image = UIImage(systemName: "person.crop.circle")
        loginBarButton.title = "login"
        self.navigationItem.rightBarButtonItem = loginBarButton
        
    }
    
    @objc func login() {
        guard let url = oauthClient.authURL else { return }
        let session = ASWebAuthenticationSession(url: url,
                                                 callbackURLScheme: GitHubConstants.callbackURLScheme)
        { [weak viewModel] callbackURL, error in
            viewModel?.handleGitHubAuthCallback(callbackURL, error: error)
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
        
}

extension SearchViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}

extension SearchViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        // TODO: grab repo object here
        return {
            let node = ASCellNode()
            node.backgroundColor = .blue
            return node
        }
    }
}

extension SearchViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.view.bounds.width, height: 100)
        let max = CGSize(width: self.view.bounds.width, height: 200)
        return ASSizeRange(min: min, max: max)
    }
}

