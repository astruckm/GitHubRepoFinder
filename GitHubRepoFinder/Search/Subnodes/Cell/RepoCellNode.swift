//
//  RepoCellNode.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/23/22.
//

import AsyncDisplayKit
import SwiftUI

class RepoCellNode: ASCellNode {
    let firstImage = ASNetworkImageNode()
    let title = ASTextNode()
    let shortDescription = ASTextNode()
    let language = ASTextNode()
    let starsLabel = ASTextNode()
    
    let topPadding: CGFloat = 2
    
    var imageURLIsNil: Bool { return firstImage.url == nil }
    
    override init() {
        super.init()
        addSubnode(firstImage)
        addSubnode(title)
        addSubnode(shortDescription)
        addSubnode(language)
        addSubnode(starsLabel)
        configure()
                
        shortDescription.style.preferredSize = CGSize(width: 200, height: 100)
        firstImage.style.preferredSize = CGSize(width: 40, height: 60)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: topPadding, left: 4, bottom: 0, right: 0), child: firstImage)
        let langStarsHStack = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 4,
                                                justifyContent: .end,
                                                alignItems: .end,
                                                children: [language, starsLabel])
        let titleLangStarsHStack = ASStackLayoutSpec(direction: .horizontal,
                                                     spacing: 4,
                                                     justifyContent: .spaceBetween,
                                                     alignItems: .center,
                                                     children: [title, langStarsHStack])
        let allTextVStack = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 0,
                                           justifyContent: .start,
                                           alignItems: .start,
                                           children: [titleLangStarsHStack, shortDescription])

        
        let finalHStack = ASStackLayoutSpec(direction: .horizontal,
                                       spacing: 24,
                                       justifyContent: .start,
                                       alignItems: .start,
                                       children: [imageInsetSpec, allTextVStack])
        let contentStack = imageURLIsNil ? allTextVStack : finalHStack
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 4), child: contentStack)
    }
    
    func configure(with viewData: RepoCellViewData? = nil) {
        if let viewData = viewData {
            firstImage.url = viewData.imageURL
            let titleText = viewData.title
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18)]
            title.attributedText = NSAttributedString(string: titleText, attributes: titleAttrs)
            shortDescription.attributedText = NSAttributedString(string: viewData.description)
            language.attributedText = NSAttributedString(string: viewData.language)
            let starsText = String(viewData.numStars) + " Stars"
            starsLabel.attributedText = NSAttributedString(string: String(starsText))
        }
        transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
    }
}


struct RepoCellNodeSwiftUI: UIViewRepresentable {
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        let cell = RepoCellNode()
        cell.configure(with: RepoCellViewData(title: "MyRepo", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", language: "Swift", numStars: 78, repoFullHTML: nil, imageURL: nil))
        let view = cell.view
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct RepoCellNodeSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        RepoCellNodeSwiftUI()
    }
}
