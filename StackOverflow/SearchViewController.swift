//
//  SearchViewController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import UIKit
import Combine

import Layout


private let checkmarkImage = UIImage(systemName: "checkmark")


///
/// Table cell used to display search results.
///
final class SearchResultTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "ThemeColor")
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
        view.tintColor = .systemGreen
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Background color and padding
        let backgroundView = UIStackView.vertical(
            contents: [
                HorizontalDividerView(),
                ColorView(
                    color: UIColor(named: "PrimaryBackgroundColor")!
                ),
                HorizontalDividerView(),
            ]
        )
        .margin(
            insets: UIEdgeInsets(
                horizontal: 0,
                vertical: 4
            )
        )
        backgroundView.translatesAutoresizingMaskIntoConstraints = true
        self.backgroundView = backgroundView

        // Content layout
        UIStackView.horizontal(
            spacing: 16,
            alignment: .fill,
            contents: [
                answeredImageView
                    .size(width: 20),
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
                vertical: 12
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
        answeredImageView.image = viewModel.answered ? checkmarkImage : nil
    }
}


///
/// Search view controller used to display search results.
///
final class SearchViewController: UITableViewController {

    private let backgroundView: BackgroundContainerView = {
        let view = BackgroundContainerView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    private let searchBar: UISearchBar = {
        let view = UISearchBar(frame: .zero)
        return view
    }()
    
    private let viewModel: SearchViewModel
    private var resultsCancellable: AnyCancellable?
    private var tableDataSource: UITableViewDiffableDataSource<Int, SearchViewModel.Results.Item>?

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.autocapitalizationType = .none
        searchBar.searchTextField.placeholder = NSLocalizedString("search-prompt", comment: "")
        searchBar.returnKeyType = .done
        searchBar.tintColor = UIColor(named: "ThemeTextColor")
        searchBar.showsCancelButton = true
        
        let searchTextField = searchBar.searchTextField
        searchTextField.backgroundColor = UIColor(named: "PrimaryBackgroundColor")
        searchTextField.leftView?.tintColor = UIColor(named: "PrimaryTextColor")?.withAlphaComponent(0.5)
        searchTextField.tintColor = UIColor(named: "PrimaryTextColor")
        searchTextField.textColor = UIColor(named: "PrimaryTextColor")

        // Place the search bar in the navigation bar.
        navigationItem.titleView = {
            let containerView = SearchBarContainerView(customSearchBar: searchBar)
            containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
            return containerView
        }()

        // Monitor when the search button is tapped, and start/end editing.
        searchBar.delegate = self
        
        // Configure refresh control (pull-down to refresh)
        refreshControl = UIRefreshControl()
        refreshControl?.addAction(
            UIAction { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.viewModel.refresh()
            },
            for: .valueChanged
        )
        
        // Configure table view
        let cellIdentifier = "ResultCell"
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.backgroundColor = UIColor(named: "TertiaryBackgroundColor")
        tableView.autoresizesSubviews = true
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.rowHeight = 80 + 8
        tableView.backgroundView = backgroundView
        tableView.refreshControl = refreshControl
        tableView.tableHeaderView = {
            let frame = CGRect(x: 0, y: 0, width: 0, height: 16)
            let view = UIView(frame: frame)
            return view
        }()
        tableView.tableFooterView = UIView()
        
        tableDataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? SearchResultTableViewCell {
                    cell.configure(with: item)
                }
                cell.separatorInset = .zero
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        )
        tableDataSource?.defaultRowAnimation = .bottom
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Observe the model and update the UI
        resultsCancellable = viewModel
            .results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else {
                    return
                }
                self.updateSearchStatus(status: status)
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop observing the model
        resultsCancellable?.cancel()
        resultsCancellable = nil
    }
    
    private func performQuery(query: String) {
        if query.isEmpty == false {
            setBackground(activeView())
        }
        setResults([], animated: true)
        viewModel.search(query: query)
    }

    private func updateSearchStatus(status: SearchViewModel.Status?) {
        switch status {
        case .none:
            showPlaceholderViewState()
        case .error(let error):
            showErrorViewState(error)
        case .noResults(let description):
            showEmptyViewState(description)
        case .results(let results):
            showResultsViewState(results)
        }
    }
    
    private func showPlaceholderViewState() {
        setBackground(placeholderView())
        setResults([], animated: true)
    }
    
    private func showErrorViewState(_ error: String) {
        setBackground(errorView(error: error))
        setResults([], animated: true)
    }
    
    private func showEmptyViewState(_ description: String) {
        setBackground(emptyView(description: description))
        setResults([], animated: true)
    }
    
    private func showResultsViewState(_ results: SearchViewModel.Results) {
        setBackground(nil)
        setResults(results.items, animated: true)
    }
    
    private func setResults(_ results: [SearchViewModel.Results.Item], animated: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchViewModel.Results.Item>()
        if results.count > 0 {
            snapshot.appendSections([0])
            snapshot.appendItems(results, toSection: 0)
        }
        tableDataSource?.apply(snapshot, animatingDifferences: animated, completion: nil)
    }
    
    private func setBackground(_ view: UIView?) {
        dispatchPrecondition(condition: .onQueue(.main))
        backgroundView.contentView = view
    }

    private func placeholderView() -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.caption = NSLocalizedString("search-placeholder", comment: "")
        view.iconImage = UIImage(systemName: "magnifyingglass")
        return view
    }
    
    private func activeView() -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.caption = NSLocalizedString("search-activity", comment: "")
        view.activityIndicatorVisible = true
        return view
    }

    private func emptyView(description: String) -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.iconImage = UIImage(systemName: "list.bullet")
        view.caption = description
        return view
    }
    
    private func errorView(error: String) -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.iconImage = UIImage(systemName: "wifi.exclamationmark")
        view.caption = Localization.shared.formattedString(named: "search-error %@", error)
        return view
    }
    
    // Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = tableDataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        let viewController = QuestionViewController(
            viewModel: viewModel
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performQuery(query: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.searchTextField.resignFirstResponder()
        performQuery(query: "")
    }
}
