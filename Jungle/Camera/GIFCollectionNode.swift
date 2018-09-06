//
//  GIFCollectionNode.swift
//  Jungle
//
//  Created by Robert Canton on 2018-09-03.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol GIFCollectionDelegate:class {
    func didSelect(gif:GIF?)
}

class GIFCollectionNode:ASDisplayNode, ASCollectionDelegate, ASCollectionDataSource, MosaicCollectionViewLayoutDelegate {
    
    var searchBar:RCSearchBarView!
    var collectionNode:ASCollectionNode!
    var tableNode = SearchResultsTableNode(style: .plain)
    
    weak var delegate:GIFCollectionDelegate?
    
    var searchResults = [String]()
    struct State {
        var gifs:[GIF]
        var fetchingMore:Bool
        var endReached:Bool
        var searchQuery:String?
        var next:String?
        static let empty = State(gifs: [], fetchingMore: false, endReached: false, searchQuery:nil, next:nil)
    }
    
    enum Action {
        case beginBatchFetch
        case endBatchFetch(gifs:[GIF], next:String?)
        case search(query:String?)
    }
    
    var state = State.empty
    var searchState = State.empty
    var currentState:State {
        return isSearching ? searchState : state
    }
    
    var isSearching = false
    
    let _layoutInspector = MosaicCollectionViewLayoutInspector()
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        let layout = MosaicCollectionViewLayout()
        layout.numberOfColumns = 3
        layout.scrollDirection = .vertical
        layout.delegate = self
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        
        collectionNode.layoutInspector = _layoutInspector
        collectionNode.backgroundColor = UIColor.white
        collectionNode.contentInset = UIEdgeInsetsMake(0, 0, 44+32, 0)
        collectionNode.reloadData()
        
        tableNode.selectedSearchResult = didSearch
        
    }
    
    override func didLoad() {
        super.didLoad()
        collectionNode.view.showsVerticalScrollIndicator = false
        beginBatchFetch()
        
        searchBar = RCSearchBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44.0), topInset: 0)
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        searchBar.setup(withDelegate: self)
        searchBar.textBubble.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        searchBar.textField.textColor = UIColor.black
        searchBar.textField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
            NSAttributedStringKey.font: Fonts.medium(ofSize: 16.0),
            NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.5)
            ])
        searchBar.rightButton.setTitleColor(UIColor.black, for: .normal)
        searchBar.clearButton.tintColor = UIColor.black
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.0).cgColor,
                           UIColor.black.withAlphaComponent(0.45).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x:0, y: 0)
        gradient.endPoint = CGPoint(x:0, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 72)
        
        let overlay = UIView(frame:view.bounds)
        
        overlay.isUserInteractionEnabled = false
        overlay.layer.addSublayer(gradient)
        view.addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlay.heightAnchor.constraint(equalToConstant: 72).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.layoutIfNeeded()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let overlay = ASOverlayLayoutSpec(child: collectionNode, overlay: tableNode)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(44, 0, 0, 0), child: overlay)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return currentState.gifs.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let gif = currentState.gifs[indexPath.row]
        let cell = GIFCellNode(gif: gif)
        return cell
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GIFCellNode
        cell?.setSelected(true)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GIFCellNode
        cell?.setSelected(false)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GIFCellNode
        cell?.setSelected(true)
        delegate?.didSelect(gif: currentState.gifs[indexPath.row])
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionNode.nodeForItem(at: indexPath) as? GIFCellNode
        cell?.setSelected(false)
    }
    
    
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        let gif = currentState.gifs[originalItemSizeAtIndexPath.row]
        return gif.contentSize
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /* Texture batching was not working properly with this
         CollectionView Layout so this is a alternative */
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * 3.0 {
            beginBatchFetch()
        }
    }
    
    func beginBatchFetch() {
        if isSearching, !searchState.fetchingMore,
            let query = searchState.searchQuery {
            let _state = self.searchState
            searchState = GIFCollectionNode.handleAction(_state, action: .beginBatchFetch)
            
            GIFService.search(withQuery: query, next: searchState.next) { _query, _gifs, _next in
                
                let oldState = self.searchState
                if oldState.searchQuery != _query { return }
                if !self.isSearching { return }
                
                if _gifs.count == 0 {
                    self.searchState = GIFCollectionNode.handleAction(oldState, action: .endBatchFetch(gifs: [], next: _next))
                    return
                }
                
                self.searchState = GIFCollectionNode.handleAction(oldState, action: .endBatchFetch(gifs: _gifs, next: _next))
                
                let newItems = (oldState.gifs.count..<self.searchState.gifs.count).map { index in
                    IndexPath(row: index, section:0)
                }
                
                self.collectionNode.insertItems(at: newItems)
                
            }
            
        } else if !isSearching, !state.fetchingMore {
            state = GIFCollectionNode.handleAction(state, action: .beginBatchFetch)
            GIFService.getTrendingGIFs(next:state.next) { _gifs, _next in
                if self.isSearching { return }
                if _gifs.count == 0 {
                    self.state = GIFCollectionNode.handleAction(self.state, action: .endBatchFetch(gifs: [], next: _next))
                    return
                }
                
                let oldState = self.state
                self.state = GIFCollectionNode.handleAction(oldState, action: .endBatchFetch(gifs: _gifs, next: _next))
                
                self.collectionNode.performBatchUpdates({
                    let newItems = (oldState.gifs.count..<self.state.gifs.count).map { index in
                        IndexPath(row: index, section:0)
                    }
                    self.collectionNode.insertItems(at: newItems)
                }, completion: nil)
                
            }
        }
        
    }
    
    static func handleAction(_ state:State, action:Action) -> State {
        var state = state
        switch action {
        case .beginBatchFetch:
            state.fetchingMore = true
            break
        case let .endBatchFetch(gifs,next):
            state.gifs.append(contentsOf: gifs)
            state.fetchingMore = false
            if gifs.count == 0 {
                state.endReached = true
            }
            state.next = next
            break
        case let .search(query):
            state = .empty
            state.searchQuery = query
            break
        }
        return state
    }
    
    func didSearchTextChange(_ text: String?) {
        if let text = text, text != "" {
            GIFService.autoComplete(query: text) { results in
                //                if self.searchView.searchBarTextField.isFirstResponder {
                //                    self.tableNode.results = results
                //                }
            }
        } else {
            self.tableNode.results = []
        }
        
    }
    
    func didSearchBegin() {
        GIFService.clearCurrentTask()
    }
    
    func didSearchEnd() {
        GIFService.clearCurrentTask()
        searchState = .empty
        isSearching = false
        collectionNode.reloadData()
    }
    
    func didSearch(_ text:String) {
        self.tableNode.results = []
        isSearching = true
        searchState = GIFCollectionNode.handleAction(self.searchState, action: .search(query: text))
        collectionNode.reloadData()
        beginBatchFetch()
    }
    
}

extension GIFCollectionNode: RCSearchBarDelegate {
    func handleLeftButton() {
        
    }
    
    func searchTextDidChange(_ text: String?) {
        
    }
    
    func searchDidBegin() {
        print("searchDidBegin")
    }
    
    func searchDidEnd() {
        print("searchDidEnd")
    }
    
    func searchTapped(_ text: String) {
        print("SEARCH TAPPED")
        self.tableNode.results = []
        searchBar.setText(text)
        //searchBar.beginEditing()
        isSearching = true
        searchState = GIFCollectionNode.handleAction(self.searchState, action: .search(query: text))
        collectionNode.reloadData()
        beginBatchFetch()
    }
    
    
}

class GIFCellNode:ASCellNode {
    var imageNode = ASNetworkImageNode()
    
    required init (gif:GIF) {
        super.init()
        backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        automaticallyManagesSubnodes = true
        imageNode.shouldCacheImage = true
        imageNode.url = gif.low_url
        self.layer.borderColor = accentColor.cgColor
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: imageNode)
    }
    
    func setSelected(_ selected:Bool) {
        if selected {
            self.layer.borderWidth = 4.0
        } else {
            self.layer.borderWidth = 0.0
        }
    }
}
