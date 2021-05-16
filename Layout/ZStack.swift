//
//  ZStack.swift
//  Layout
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit

// Displays a collection of subviews stacked on top of each other.
public final class ZStack: UIView {
    
    public var contents: [UIView] = [] {
        didSet {
            invalidateContents(old: oldValue, new: contents)
        }
    }
    
    public init(contents: [UIView]) {
        super.init(frame: .zero)
        self.contents = contents
        invalidateContents(old: [], new: contents)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func invalidateContents(old: [UIView], new: [UIView]) {
        old.forEach { $0.removeFromSuperview() }
        new.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            NSLayoutConstraint.activate([
                view.leftAnchor.constraint(
                    equalTo: leftAnchor
                ),
                view.rightAnchor.constraint(
                    equalTo: rightAnchor
                ),
                view.topAnchor.constraint(
                    equalTo: topAnchor
                ),
                view.bottomAnchor.constraint(
                    equalTo: bottomAnchor
                ),
            ])
        }
    }
}
