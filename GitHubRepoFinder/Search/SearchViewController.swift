//
//  SearchViewController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/9/22.
//

import AsyncDisplayKit
import AuthenticationServices

class SearchViewController: ASDKViewController<ASDisplayNode> {
    let searchDisplayNode: SearchDisplayNode
    
    let viewModel: SearchViewModel
    let oauthClient = GitHubOAuthClient()
    
    override init() {
        viewModel = SearchViewModel()
        searchDisplayNode = SearchDisplayNode()
        let baseNode = ASDisplayNode()
        baseNode.addSubnode(searchDisplayNode)
        super.init(node: baseNode)
        
        self.node.layoutSpecBlock = { node, constrainedSize in
            let isPortrait = (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown)
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: isPortrait ? 68 : 44, left: 0, bottom: 0, right: 0), child: self.searchDisplayNode)
        }
        viewModel.updateAllRepos = { [weak self] viewData in
            self?.searchDisplayNode.dataSource.viewData = viewData
            DispatchQueue.main.async {
                self?.searchDisplayNode.tableNode.reloadData()
            }
        }
        viewModel.updateRepo = { [weak self] (indexPath, viewData) in
            guard let self = self else { return }
            guard indexPath.row < self.searchDisplayNode.dataSource.viewData.count else { return }
            self.searchDisplayNode.dataSource.viewData[indexPath.row] = viewData
            DispatchQueue.main.async {
                self.searchDisplayNode.tableNode.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        searchDisplayNode.textCallback = { [weak self] searchText in
            self?.searchDisplayNode.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            self?.viewModel.getRepos(with: searchText)
        }
        searchDisplayNode.rowSelectionAction = { [weak self] indexPath in
            guard let viewData = self?.viewModel.reposViewData, indexPath.row < viewData.count else { return }
            let viewDatum = viewData[indexPath.row]
            let detailVC = RepoDetailViewController(readMe: viewDatum.readMeFullHTML ?? "")
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        viewModel = SearchViewModel()
        searchDisplayNode = SearchDisplayNode()
        super.init(coder: coder)
        
        searchDisplayNode.textCallback = { [weak self] searchText in
            self?.viewModel.getRepos(with: searchText)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.backgroundColor = .systemGray6
        self.navigationItem.title = "Repo Finder"
        let loginBarButton = UIBarButtonItem()
        loginBarButton.action = #selector(login)
        loginBarButton.target = self
        loginBarButton.image = UIImage(systemName: "person.crop.circle")
        loginBarButton.title = "login"
        self.navigationItem.rightBarButtonItem = loginBarButton
        
        viewModel.loadReposViewData()
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
