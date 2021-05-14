//
//  MarginView.swift
//  Layout
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit


extension UIView {
    public func margin(insets: UIEdgeInsets) -> MarginView {
        MarginView(insets: insets, contents: self)
    }
}


public final class MarginView: UIView {
    
    public var contents: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            invalidateContent()
        }
    }
    
    public init(insets: UIEdgeInsets? = nil, contents: UIView?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        if let insets = insets {
            self.layoutMargins = insets
        }
        self.contents = contents
        invalidateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func invalidateContent() {
        guard let contentView = contents else {
            return
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(
                equalTo: layoutMarginsGuide.leftAnchor
            ),
            contentView.rightAnchor.constraint(
                equalTo: layoutMarginsGuide.rightAnchor
            ),
            contentView.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor
            ),
        ])
    }
    
    public override class var layerClass: AnyClass {
        CATransformLayer.self
    }
}
