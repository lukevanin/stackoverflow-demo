//
//  QuestionViewController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit
import WebKit

final class QuestionViewController: UIViewController {
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private let authorReputationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private let askedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private let authorProfileImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private let contentTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.contentInset = UIEdgeInsets(
            top: 8,
            left: 16,
            bottom: 8,
            right: 16
        )
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.alwaysBounceVertical = true
        return view
    }()

    private let model: SearchResultViewModel
    
    init(model: SearchResultViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .systemGray
            view.addSubview(headerLabel)
            return view
        }()

        let authorInfoLayout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    authorNameLabel,
                    authorReputationLabel,
                    askedDateLabel,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .vertical
            layout.spacing = 8
            layout.alignment = .leading
            return layout
        }()

        let tagsContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .systemBackground
            view.addSubview(tagsLabel)
            return view
        }()

        let authorLayout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    authorProfileImageView,
                    authorInfoLayout,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .horizontal
            layout.spacing = 8
            layout.alignment = .leading
            return layout
        }()
        
        let authorContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .systemGray
            view.addSubview(authorLayout)
            return view
        }()

        let layout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    headerContainer,
                    contentTextView,
                    tagsContainer,
                    authorContainer,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .vertical
            layout.spacing = 0
            layout.alignment = .fill
            return layout
        }()
        
        view.backgroundColor = .systemBackground
        view.addSubview(layout)

        NSLayoutConstraint.activate([
            // Header
            headerContainer.heightAnchor.constraint(
                equalToConstant: 55
            ),
            headerLabel.leftAnchor.constraint(
                equalToSystemSpacingAfter: headerContainer.leftAnchor,
                multiplier: 2
            ),
            headerContainer.rightAnchor.constraint(
                equalToSystemSpacingAfter: headerLabel.rightAnchor,
                multiplier: 2
            ),
            headerLabel.centerYAnchor.constraint(
                equalTo: headerContainer.centerYAnchor
            ),
            headerLabel.heightAnchor.constraint(
                lessThanOrEqualTo: headerContainer.heightAnchor
            ),
            
            // Tags
            tagsContainer.heightAnchor.constraint(
                equalToConstant: 22
            ),
            tagsLabel.leftAnchor.constraint(
                equalToSystemSpacingAfter: tagsContainer.leftAnchor,
                multiplier: 2
            ),
            tagsContainer.rightAnchor.constraint(
                equalToSystemSpacingAfter: tagsLabel.rightAnchor,
                multiplier: 2
            ),
            tagsLabel.centerYAnchor.constraint(
                equalTo: tagsContainer.centerYAnchor
            ),
            
            // Author
            authorLayout.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 65
            ),
            authorLayout.leftAnchor.constraint(
                equalToSystemSpacingAfter: authorContainer.leftAnchor,
                multiplier: 2
            ),
            authorContainer.rightAnchor.constraint(
                equalToSystemSpacingAfter: authorLayout.rightAnchor,
                multiplier: 2
            ),
            authorLayout.topAnchor.constraint(
                equalToSystemSpacingBelow: authorContainer.topAnchor,
                multiplier: 1
            ),
            authorContainer.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalToSystemSpacingBelow: authorLayout.bottomAnchor,
                multiplier: 1
            ),

            // View
            layout.leftAnchor.constraint(
                equalTo: view.leftAnchor
            ),
            view.rightAnchor.constraint(
                equalTo: layout.rightAnchor
            ),
            layout.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            view.bottomAnchor.constraint(
                equalTo: layout.bottomAnchor
            )
        ])
        
        navigationItem.title = Localization.shared.string(named: "question-title")
        
        invalidateView()
    }
    
    private func invalidateView() {
        // Format the HTML content into a rich text string
        let data = model.content.data(using: .utf8)
        let content: NSAttributedString = data.flatMap { data -> NSAttributedString? in
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            return try? NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )
        } ?? NSAttributedString(string: model.content)
        let formattedContent: NSAttributedString = {
            #warning("TODO: Customize foreground text")
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label
            ]
            let range = NSRange(location: 0, length: content.length)
            let output = NSMutableAttributedString(attributedString: content)
            output.setAttributes(attributes, range: range)
            return output
        }()


        let localization = Localization.shared
        headerLabel.text = model.title
        authorNameLabel.text = model.owner.displayName
        if let reputation = model.owner.reputation {
            authorReputationLabel.isHidden = false
            authorReputationLabel.text = localization.formatInteger(reputation)
        }
        else {
            authorReputationLabel.isHidden = true
        }
        askedDateLabel.text = localization.formattedString(named: "asked-on %@ at %@", localization.formatDate(model.askedDate), localization.formatTime(model.askedDate))
        contentTextView.attributedText = formattedContent
        tagsLabel.text = model.tags.joined(separator: ", ")
        #warning("TODO: Load the author profile image")
        authorProfileImageView.isHidden = true
    }
}
