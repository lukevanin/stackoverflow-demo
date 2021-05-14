//
//  UIKitExtensions.swift
//  Layout
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit


extension UIEdgeInsets {
    
    public init(all margin: CGFloat) {
        self.init(
            top: margin,
            left: margin,
            bottom: margin,
            right: margin
        )
    }

    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }
}


extension UIStackView {
    
    public static func vertical(
        spacing: CGFloat? = nil,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        contents: [UIView]
    ) -> UIStackView {
        return stack(
            axis: .vertical,
            spacing: spacing,
            alignment: alignment,
            distribution: distribution,
            contents: contents
        )
    }
    
    public static func horizontal(
        spacing: CGFloat? = nil,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        contents: [UIView]
    ) -> UIStackView {
        return stack(
            axis: .horizontal,
            spacing: spacing,
            alignment: alignment,
            distribution: distribution,
            contents: contents
        )
    }

    static func stack(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat? = nil,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        contents: [UIView]
    ) -> UIStackView {
        contents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let view = UIStackView(arrangedSubviews: contents)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = axis
        if let spacing = spacing {
            view.spacing = spacing
        }
        if let alignment = alignment {
            view.alignment = alignment
        }
        if let distribution = distribution {
            view.distribution = distribution
        }
        return view
    }
}


extension UIView {
    
    public func size(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        return self
    }
    
    public func aspectRatio(_ ratio: CGFloat) -> Self {
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio).isActive = true
        return self
    }

    public func insert(into superview: UIView, at index: Int) {
        removeFromSuperview()
        superview.insertSubview(self, at: index)
        attach(to: superview)
    }

    public func add(to superview: UIView)  {
        removeFromSuperview()
        superview.addSubview(self)
        attach(to: superview)
    }
    
    public func attach(to superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftAnchor.constraint(
                equalTo: superview.leftAnchor
            ),
            rightAnchor.constraint(
                equalTo: superview.rightAnchor
            ),
            topAnchor.constraint(
                equalTo: superview.topAnchor
            ),
            bottomAnchor.constraint(
                equalTo: superview.bottomAnchor
            ),
        ])
    }
}
