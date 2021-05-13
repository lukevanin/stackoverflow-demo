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
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.textColor = UIColor(named: "SecondaryTextColor")
        return label
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textColor = UIColor(named: "SecondaryTextColor")
        return label
    }()
    
    private let authorReputationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textColor = UIColor(named: "SecondaryTextColor")
        return label
    }()
    
    private let askedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textColor = UIColor(named: "SecondaryTextColor")
        return label
    }()
    
    private let authorProfileImageView: URLImageView = {
        let view = URLImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .systemGray
        return view
    }()

    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textColor = UIColor(named: "SecondaryTextColor")
        return label
    }()
    
    private let contentTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.contentInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
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
            view.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
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
            layout.distribution = .equalSpacing
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
            view.layoutMargins = UIEdgeInsets(
                top: 8,
                left: 16,
                bottom: 8,
                right: 16
            )
            view.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
            view.addSubview(authorLayout)
            return view
        }()

        let layout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    headerContainer,
                    HorizontalDividerView(),
                    contentTextView,
                    HorizontalDividerView(),
                    tagsContainer,
                    HorizontalDividerView(),
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
                equalToConstant: 65 - (authorContainer.layoutMargins.top + authorContainer.layoutMargins.bottom)
            ),
            authorLayout.leftAnchor.constraint(
                equalTo: authorContainer.layoutMarginsGuide.leftAnchor
            ),
            authorLayout.rightAnchor.constraint(
                equalTo: authorContainer.layoutMarginsGuide.rightAnchor
            ),
            authorLayout.topAnchor.constraint(
                equalTo: authorContainer.layoutMarginsGuide.topAnchor
            ),
            authorLayout.bottomAnchor.constraint(
                equalTo: authorContainer.layoutMarginsGuide.bottomAnchor
            ),
            authorProfileImageView.widthAnchor.constraint(
                equalTo: authorProfileImageView.heightAnchor
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
        updateHeader()
        updateTags()
        updateProfileImage()
        updateAuthor()
        updateReputation()
        updateDate()
        updateBody()
    }
    
    private func updateHeader() {
        headerLabel.text = model.title
    }
    
    private func updateAuthor() {
        authorNameLabel.text = model.owner.displayName
    }
    
    private func updateReputation() {
        let localization = Localization.shared
        if let reputation = model.owner.reputation {
            authorReputationLabel.isHidden = false
            authorReputationLabel.text = localization.formatInteger(reputation)
        }
        else {
            authorReputationLabel.isHidden = true
        }
    }
    
    private func updateDate() {
        let localization = Localization.shared
        askedDateLabel.text = localization.formattedString(named: "asked-on %@ at %@", localization.formatDate(model.askedDate), localization.formatTime(model.askedDate))
    }
    
    private func updateTags() {
        tagsLabel.text = model.tags.joined(separator: ", ")
    }
    
    private func updateBody() {
        let content = model.content
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let data = content.data(using: .utf8)
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
            } ?? NSAttributedString(string: content)
            let formattedContent: NSAttributedString = {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                    .foregroundColor: UIColor(named: "PrimaryTextColor") as Any,
                ]
                let range = NSRange(location: 0, length: content.length)
                let output = NSMutableAttributedString(attributedString: content)
                output.setAttributes(attributes, range: range)
                return output
            }()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.contentTextView.attributedText = formattedContent
            }
        }
    }
    
    private func updateProfileImage() {
        if let url = model.owner.profileImageURL {
            authorProfileImageView.isHidden = false
            authorProfileImageView.url = url
        }
        else {
            authorProfileImageView.isHidden = true
        }
    }
}
