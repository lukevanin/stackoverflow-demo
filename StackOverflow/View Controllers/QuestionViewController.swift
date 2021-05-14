//
//  QuestionViewController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit
import WebKit
import SafariServices
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
    
    private let contentWebView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
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

        view.backgroundColor = UIColor(named: "PrimaryBackgroundColor")!
        
        contentWebView.navigationDelegate = self

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
                contentWebView,
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
        #warning("TODO; Move HTML into template")
        let html = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1,user-scalable=no">
            <style>
                body {
                    font-family: -apple-system;
                    font-size: 13px;
                    background-color: #\(UIColor(named: "PrimaryBackgroundColor")!.hex());
                    color: #\(UIColor(named: "PrimaryTextColor")!.hex());
                    padding: 8px;
                }
                img {
                    max-width: 100%;
                }
            </style>
            </head>
            <body>
            \(viewModel.content)
            </body>
            </html>
        """
        contentWebView.loadHTMLString(html, baseURL: nil)
    }
    
//    private func updateBody()
//        contentActivityView.startAnimating()
//        viewModel
//            .formattedBody()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] value in
//                guard let self = self else {
//                    return
//                }
//                self.contentActivityView.stopAnimating()
//                UIView.transition(
//                    with: self.view,
//                    duration: 0.25,
//                    options: [.transitionCrossDissolve],
//                    animations: {
//                        self.contentTextView.attributedText = value
//                    },
//                    completion: { _ in
//                        self.contentActivityView.removeFromSuperview()
//                    }
//                )
//            }
//            .store(in: &cancellables)
//    }
    
    private func updateProfileImage() {
        if let url = viewModel.owner.profileImageURL {
            authorProfileImageView.isHidden = false
            authorProfileImageView.url = url
        }
        else {
            authorProfileImageView.isHidden = true
        }
    }
    
    private func navigate(to url: URL) {
        dispatchPrecondition(condition: .onQueue(.main))
        let configuration = SFSafariViewController.Configuration()
        let viewController = SFSafariViewController(
            url: url,
            configuration: configuration
        )
        present(viewController, animated: true, completion: nil)
    }
}

extension QuestionViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            decisionHandler(.cancel)
            navigate(to: url)
        }
        else {
            decisionHandler(.allow)
        }
    }
}
