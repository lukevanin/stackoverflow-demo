//
//  ColorView.swift
//  Layout
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit


extension UIView {
    public func color(_ color: UIColor) -> ColorView {
        ColorView(color: color, contents: self)
    }
}


/// Displays a solid color. Contains a sub-view.
public final class ColorView: UIView {
    
    public var color: UIColor {
        get {
            backgroundColor ?? .clear
        }
        set {
            backgroundColor = newValue
        }
    }
    
    public var contents: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            invalidateContent()
        }
    }
    
    public init(color: UIColor? = nil, contents: UIView? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = color
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
                equalTo: leftAnchor
            ),
            contentView.rightAnchor.constraint(
                equalTo: rightAnchor
            ),
            contentView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
        ])
    }
}
