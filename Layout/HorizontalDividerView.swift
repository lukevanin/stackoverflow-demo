//
//  HorizontalDividerView.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit

public final class HorizontalDividerView: UIView {
    
    public var height: CGFloat {
        didSet {
            guard height != oldValue else {
                return
            }
            invalidateHeight()
        }
    }
    
    private var heightConstraint: NSLayoutConstraint!

    public init(height: CGFloat = 1) {
        self.height = height
        super.init(frame: .zero)
        heightConstraint = heightAnchor.constraint(
            equalToConstant: 0
        )
        heightConstraint.isActive = true
        isOpaque = true
        backgroundColor = UIColor(named: "DividerColor")
        translatesAutoresizingMaskIntoConstraints = false
        invalidateHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func invalidateHeight() {
        heightConstraint.constant = height / UIScreen.main.scale
    }
}
