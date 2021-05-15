//
//  SearchBarContainerView.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit


/// See: https://stackoverflow.com/a/46618780/762377
class SearchBarContainerView: UIView {

    var minimumHeight: CGFloat = 32
    var maximumHeight: CGFloat = 44
    let searchBar: UISearchBar
    
    /// See: https://stackoverflow.com/a/44932834/762377
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        searchBar.translatesAutoresizingMaskIntoConstraints = true
        addSubview(searchBar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = max(min(bounds.height, maximumHeight), minimumHeight)
        searchBar.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: height
        )
    }
}
