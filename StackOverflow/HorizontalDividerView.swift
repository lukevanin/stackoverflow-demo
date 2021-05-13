//
//  HorizontalDividerView.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit

final class HorizontalDividerView: UIView {

    init(height: CGFloat = 1) {
        super.init(frame: .zero)
        heightAnchor
            .constraint(
                equalToConstant: height / UIScreen.main.scale
            )
            .isActive = true
        isOpaque = true
        backgroundColor = UIColor(named: "DividerColor")
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
