//
//  SearchResultTableViewCell.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit

import Layout


///
/// Table cell used to display search results.
///
final class SearchResultTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "ThemeAccentColor")
        label.numberOfLines = 2
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor(named: "SecondaryTextColor")
        label.numberOfLines = 1
        return label
    }()
    
    private let votesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor(named: "SecondaryTextColor")
        label.numberOfLines = 1
        return label
    }()
    
    private let answersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor(named: "SecondaryTextColor")
        label.numberOfLines = 1
        return label
    }()
    
    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor(named: "SecondaryTextColor")
        label.numberOfLines = 1
        return label
    }()
    
    private let answeredImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(named: "SelectionColor")
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundColor = .magenta

        // Background color and padding
        let backgroundView = UIStackView.vertical(
            contents: [
                HorizontalDividerView(
                    height: 8,
                    color: UIColor(named: "TertiaryBackgroundColor")
                ),
                HorizontalDividerView(),
                ColorView(
                    color: UIColor(named: "PrimaryBackgroundColor")!
                ),
                HorizontalDividerView(),
                HorizontalDividerView(
                    height: 8,
                    color: UIColor(named: "TertiaryBackgroundColor")
                ),
            ]
        )
        backgroundView.translatesAutoresizingMaskIntoConstraints = true
        self.backgroundView = backgroundView

        // Content layout.
        UIStackView.horizontal(
            spacing: 16,
            alignment: .fill,
            contents: [
                answeredImageView.size(width: 20),
                UIStackView.vertical(
                    alignment: .leading,
                    distribution: .equalSpacing,
                    contents: [
                        titleLabel,
                        ownerLabel,
                    ]
                ),
                UIStackView.vertical(
                    alignment: .leading,
                    distribution: .equalSpacing,
                    contents: [
                        votesLabel,
                        answersLabel,
                        viewsLabel,
                    ]
                )
                .size(width: 100),
            ]
        )
        .margin(
            insets: UIEdgeInsets(
                horizontal: 16,
                vertical: 16
            )
        )
        .add(to: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: SearchViewModel.Results.Item) {
        titleLabel.text = viewModel.title
        ownerLabel.text = viewModel.owner.displayName
        votesLabel.text = viewModel.votes
        answersLabel.text = viewModel.answers
        viewsLabel.text = viewModel.views
        answeredImageView.image = viewModel.answered ? UIImage(systemName: "checkmark") : nil
    }
}
