//
//  SearchBarContainerView.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit


/// See: https://stackoverflow.com/a/46618780/762377
class SearchBarContainerView: UIView {

    let searchBar: UISearchBar

    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        addSubview(searchBar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height - 8
        )
    }
}
