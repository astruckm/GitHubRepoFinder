//
//  ViewController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/9/22.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    let client = GitHubAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = client.generateAuthURL() else { return }
        print("url: ", url)
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "abc") { callbackURL, error in
            print("got back url: \(callbackURL), error: \(error)")
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
        
        
        let gitHubClientStr = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT") as? String
        let gitHubClientIdStr = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_ID") as? String
        if let gitHubClientStr = gitHubClientStr {
            print("gitHubClientStr", gitHubClientStr)
        } else {
            print("No GitHub Client Secret")
        }
        if let gitHubClientIdStr = gitHubClientIdStr {
            print("gitHubClientIdStr", gitHubClientIdStr)
        } else {
            print("No GitHub Client ID string")
        }
    }


}

extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}

