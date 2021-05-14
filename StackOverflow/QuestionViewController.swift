//
//  QuestionViewController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit
import Combine

import Layout

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

    private let viewModel: SearchViewModel.Results.Item
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: SearchViewModel.Results.Item) {
        self.viewModel = viewModel
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
//                    authorLayout.layout.margin(
//                        insets: UIEdgeInsets(horizontal: 16, vertical: 8)
//                    )
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
                equalToConstant: 65 - 16
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
        headerLabel.text = viewModel.title
    }
    
    private func updateAuthor() {
        authorNameLabel.text = viewModel.owner.displayName
    }
    
    private func updateReputation() {
        if let reputation = viewModel.owner.reputation {
            authorReputationLabel.isHidden = false
            authorReputationLabel.text = reputation
        }
        else {
            authorReputationLabel.isHidden = true
        }
    }
    
    private func updateDate() {
        askedDateLabel.text = viewModel.askedDate
    }
    
    private func updateTags() {
        tagsLabel.text = viewModel.tags
    }
    
    private func updateBody() {
        viewModel
            .formattedBody()
            .receive(on: DispatchQueue.main)
            .assign(to: \.attributedText, on: contentTextView)
            .store(in: &cancellables)
    }
    
    private func updateProfileImage() {
        if let url = viewModel.owner.profileImageURL {
            authorProfileImageView.isHidden = false
            authorProfileImageView.url = url
        }
        else {
            authorProfileImageView.isHidden = true
        }
    }
}
