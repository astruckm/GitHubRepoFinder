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
    let client = GitHubAPIClient()
    
    override init() {
        let node = ASDisplayNode()
        super.init(node: node)
        
        // TODO: can set data source, delegate here
    }
    
    required init?(coder: NSCoder) {
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
        guard let url = client.generateAuthURL else { return }
        let session = ASWebAuthenticationSession(url: url,
                                                 callbackURLScheme: GitHubConstants.callbackURLScheme)
        { [weak self] callbackURL, error in
            print("got back url: \(callbackURL), error: \(error)")
            guard error == nil,
                  let callbackURL = callbackURL,
                  let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
                  let code = queryItems.first(where: { $0.name == "code" })?.value,
                  let url = self?.client.generateAccessTokenURL(with: code)
            else {
                print("An error occurred when attempting to sign in.")
                return
            }
            self?.getAccessToken(url: url)
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    func getAccessToken(url: URL) {
        client.load(fromURL: url, with: .codeExchange(code: ""), responseType: String.self) { [weak self] result in
            switch result {
            case .success(let str):
                print("success result: ", str)
                self?.getUser()
            case .failure(let err):
                print("failure with error: ", err)
            }
        }
    }
    
    
    func getUser() {
        guard let getUserURL = client.userURL else { return }
        client.load(fromURL: getUserURL, with: .getUser, responseType: User.self) { result in
            switch result {
            case .success(let user):
                print("User is: ", user)
            case .failure(let error):
                print("error getting user: ", error)
            }
        }
    }
    
}




extension SearchViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}

