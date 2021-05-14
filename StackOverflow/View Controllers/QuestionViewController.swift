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
        view.contentInset = UIEdgeInsets(all: 16)
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.alwaysBounceVertical = true
        return view
    }()
    
    private let contentActivityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = UIColor(named: "SecondaryTextColor")
        view.hidesWhenStopped = true
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
        
        navigationItem.title = Localization.shared.string(named: "question-title")

        view.backgroundColor = .systemBackground

        // Layout
        UIStackView.vertical(
            alignment: .fill,
            contents: [
                // Header
                headerLabel
                    .size(height: 55)
                    .margin(insets: UIEdgeInsets(horizontal: 16, vertical: 0))
                    .color(UIColor(named: "SecondaryBackgroundColor")!),
                HorizontalDividerView(),
                // Content
                contentActivityView,
                contentTextView,
                HorizontalDividerView(),
                // Tags
                tagsLabel
                    .size(height: 22)
                    .margin(insets: UIEdgeInsets(horizontal: 16, vertical: 0))
                    .color(UIColor(named: "PrimaryBackgroundColor")!),
                HorizontalDividerView(),
                // Profile
                UIStackView.horizontal(
                    spacing: 16,
                    alignment: .fill,
                    contents: [
                        authorProfileImageView.aspectRatio(1.0),
                        UIStackView.vertical(
                            alignment: .leading,
                            distribution: .equalSpacing,
                            contents: [
                                authorNameLabel,
                                authorReputationLabel,
                                askedDateLabel,
                            ]
                        ),
                    ]
                )
                .size(height: 65 - 24)
                .margin(insets: UIEdgeInsets(horizontal: 16, vertical: 12))
                .color(UIColor(named: "SecondaryBackgroundColor")!)
            ])
            .add(to: view)
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
        contentActivityView.startAnimating()
        viewModel
            .formattedBody()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                self.contentTextView.attributedText = value
                self.contentActivityView.stopAnimating()
            }
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
