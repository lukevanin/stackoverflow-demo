//
//  BackgroundContainerView.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit
import Combine

class BackgroundContainerView: UIView {

    var animationDuration: TimeInterval = 0.25
    
    var contentView: UIView? {
        didSet {
            updateView(oldView: oldValue, newView: contentView)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "TertiaryBackgroundColor")
        layoutMargins = .zero
        let notificationCenter = NotificationCenter.default
        notificationCenter.publisher(
            for: UIResponder.keyboardWillChangeFrameNotification
        )
        .sink { [weak self] notification in
            guard let self = self else {
                return
            }
            self.invalidateKeyboard(info: notification.userInfo ?? [:])
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func invalidateKeyboard(info: [AnyHashable : Any]) {
        guard let window = window else {
            return
        }
        guard let endFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let windowEndFrame = endFrameValue.cgRectValue
        let localEndFrame = convert(windowEndFrame, from: window.coordinateSpace)
        let localOverlap = bounds.intersection(localEndFrame)

        let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double

        let animationCurveValue = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        let animationCurve = UIView.AnimationCurve(rawValue: animationCurveValue ?? 0) ?? .linear

        self.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: localOverlap.height,
            right: 0
        )
        let animator = UIViewPropertyAnimator(
            duration: animationDuration ?? 0,
            curve: animationCurve,
            animations: {
                self.layoutIfNeeded()
            }
        )
        animator.startAnimation()
    }
    
    private func updateView(oldView: UIView?, newView: UIView?) {
        if let newView = newView {
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.isHidden = true
            addSubview(newView)
            NSLayoutConstraint.activate([
                newView.leftAnchor.constraint(
                    equalTo: layoutMarginsGuide.leftAnchor
                ),
                newView.rightAnchor.constraint(
                    equalTo: layoutMarginsGuide.rightAnchor
                ),
                newView.topAnchor.constraint(
                    equalTo: layoutMarginsGuide.topAnchor
                ),
                newView.bottomAnchor.constraint(
                    equalTo: layoutMarginsGuide.bottomAnchor
                ),
            ])
        }
        if let oldView = oldView, let newView = newView {
            UIView.transition(
                from: oldView,
                to: newView,
                duration: animationDuration,
                options: [.transitionCrossDissolve, .beginFromCurrentState, .showHideTransitionViews],
                completion: { _ in
                    oldView.removeFromSuperview()
                }
            )
        }
        else {
            UIView.transition(
                with: self,
                duration: animationDuration,
                options: [.transitionCrossDissolve],
                animations: {
                    newView?.isHidden = false
                },
                completion: { finished in
                    if finished {
                        oldView?.removeFromSuperview()
                    }
                }
            )
        }
    }
}
