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
    let viewModel: SearchViewModel
    let client = GitHubApiClient()
    let oauthClient = GitHubOAuthClient()
    
    override init() {
        let node = ASDisplayNode()
        viewModel = SearchViewModel()
        super.init(node: node)
        
        // TODO: can set data source, delegate here
    }
    
    required init?(coder: NSCoder) {
        viewModel = SearchViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = .systemBackground
        
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

