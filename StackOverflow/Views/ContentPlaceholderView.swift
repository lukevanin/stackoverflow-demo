//
//  ContentPlaceholderView.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit


/// General purpose view used for showing a placeholder icon and message where content would otherwise
/// normally appear. This is for aesthetics, but can also show useful information to the user about the reason
/// for missing content (e.g. error or an empty search result).
final class ContentPlaceholderView: UIView {
    
    var caption: String? {
        get {
            captionLabel.text
        }
        set {
            captionLabel.text = newValue
            captionLabel.isHidden = newValue == nil
        }
    }
    
    var iconImage: UIImage? {
        get {
            iconImageView.image
        }
        set {
            iconImageView.image = newValue
            iconImageView.isHidden = newValue == nil
        }
    }
    
    var activityIndicatorVisible: Bool {
        get {
            activityIndicatorView.isAnimating
        }
        set {
            if newValue {
                if activityIndicatorView.isAnimating == false {
                    activityIndicatorView.startAnimating()
                }
            }
            else {
                if activityIndicatorView.isAnimating == true {
                    activityIndicatorView.stopAnimating()
                }
            }
        }
    }
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = UIColor(named: "SecondaryTextColor")
        view.isHidden = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(named: "SecondaryTextColor")
        view.isHidden = true
        return view
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = UIColor(named: "SecondaryTextColor")
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    activityIndicatorView,
                    iconImageView,
                    captionLabel,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .vertical
            layout.spacing = 16
            layout.alignment = .center
            return layout
        }()
        addSubview(layout)
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(
                equalToConstant: 64
            ),
            iconImageView.heightAnchor.constraint(
                equalTo: iconImageView.widthAnchor
            ),
            
            layout.widthAnchor.constraint(
                equalTo: safeAreaLayoutGuide.widthAnchor,
                constant: -64
            ),
            layout.centerXAnchor.constraint(
                equalTo: safeAreaLayoutGuide.centerXAnchor
            ),
            layout.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
