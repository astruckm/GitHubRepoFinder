//
//  ViewController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/9/22.
//

import UIKit
import AsyncDisplayKit
import AuthenticationServices

class NodeViewController: ASDKViewController<ASDisplayNode> {
    let client = GitHubAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = client.generateAuthURL() else { return }
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




extension NodeViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}

