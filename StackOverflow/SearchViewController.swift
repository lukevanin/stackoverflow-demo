//
//  SearchViewController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import UIKit
import Combine


struct SearchResults {
    let tags: [String]
    let items: [SearchResultViewModel]
}


enum SearchStatus {
    case empty
    case results(SearchResults)
    case error(String)
}


protocol ISearchModel {
    var results: AnyPublisher<SearchStatus, Never> { get }
    func refresh()
    func search(query: String) -> Void
}


private let checkmarkImage = UIImage(systemName: "checkmark")


///
/// Table cell used to display search results.
///
final class SearchResultTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private let votesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private let answersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
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
        
        let statsLayout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    votesLabel,
                    answersLabel,
                    viewsLabel,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .vertical
            layout.spacing = 8
            layout.alignment = .leading
            layout.distribution = .equalSpacing
            return layout
        }()
        
        let textLayout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    titleLabel,
                    ownerLabel,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .vertical
            layout.spacing = 8
            layout.alignment = .leading
            layout.distribution = .equalSpacing
            return layout
        }()
        
        let contentLayout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    answeredImageView,
                    textLayout,
                    statsLayout,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .horizontal
            layout.spacing = 16
            layout.alignment = .fill
            return layout
        }()
        
        let contentContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor(named: "PrimaryBackgroundColor")
            view.layoutMargins = UIEdgeInsets(
                top: 8,
                left: 16,
                bottom: 8,
                right: 16
            )
            view.addSubview(contentLayout)
            return view
        }()
        
        let topDivider = HorizontalDividerView()
        
        let bottomDivider = HorizontalDividerView()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(contentContainer)
        contentView.addSubview(topDivider)
        contentView.addSubview(bottomDivider)
        NSLayoutConstraint.activate([
            answeredImageView.widthAnchor.constraint(
                equalToConstant: 20
            ),
            answeredImageView.widthAnchor.constraint(
                equalTo: answeredImageView.heightAnchor
            ),
            
            statsLayout.widthAnchor.constraint(
                equalToConstant: 100
            ),
                        
            topDivider.leftAnchor .constraint(
                equalTo: contentContainer.leftAnchor
            ),
            topDivider.rightAnchor.constraint(
                equalTo: contentContainer.rightAnchor
            ),
            topDivider.bottomAnchor.constraint(
                equalTo: contentContainer.topAnchor
            ),
            
            bottomDivider.leftAnchor .constraint(
                equalTo: contentContainer.leftAnchor
            ),
            bottomDivider.rightAnchor.constraint(
                equalTo: contentContainer.rightAnchor
            ),
            bottomDivider.topAnchor.constraint(
                equalTo: contentContainer.bottomAnchor
            ),

            contentLayout.leftAnchor .constraint(
                equalTo: contentContainer.layoutMarginsGuide.leftAnchor
            ),
            contentLayout.rightAnchor.constraint(
                equalTo: contentContainer.layoutMarginsGuide.rightAnchor
            ),
            contentLayout.topAnchor.constraint(
                equalTo: contentContainer.layoutMarginsGuide.topAnchor
            ),
            contentLayout.bottomAnchor.constraint(
                equalTo: contentContainer.layoutMarginsGuide.bottomAnchor
            ),

            contentContainer.leftAnchor .constraint(
                equalTo: leftAnchor
            ),
            contentContainer.rightAnchor.constraint(
                equalTo: rightAnchor
            ),
            contentContainer.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8
            ),
            contentContainer.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            ),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: SearchResultViewModel) {
        titleLabel.text = viewModel.title
        ownerLabel.text = String(format: NSLocalizedString("asked-by %@", comment: ""), viewModel.owner.displayName)
        votesLabel.text = String(format: NSLocalizedString("vote-count %lld", comment: ""), viewModel.votes)
        answersLabel.text = String(format: NSLocalizedString("answer-count %lld", comment: ""), viewModel.answers)
        viewsLabel.text = String(format: NSLocalizedString("view-count %lld", comment: ""), viewModel.answers)
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
    
    private let model: ISearchModel
    private var resultsCancellable: AnyCancellable?
    private var tableDataSource: UITableViewDiffableDataSource<Int, SearchResultViewModel>?

    init(model: ISearchModel) {
        self.model = model
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
        searchTextField.tintColor = UIColor(named: "ThemeColor")
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
                self.model.refresh()
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
        tableView.rowHeight = 80 + 16
        tableView.backgroundView = backgroundView
        tableView.refreshControl = refreshControl
        tableView.tableHeaderView = {
            let frame = CGRect(x: 0, y: 0, width: 0, height: 16)
            let view = UIView(frame: frame)
            return view
        }()
        tableView.tableFooterView = UIView()
        
        tableDataSource = UITableViewDiffableDataSource<Int, SearchResultViewModel>(
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
        resultsCancellable = model
            .results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self else {
                    return
                }
                self.updateSearchResults(results: results)
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
        model.search(query: query)
    }

    private func updateSearchResults(results: SearchStatus) {
        switch results {
        case .empty:
            showEmptyViewState()
        case .error(let error):
            showErrorViewState(error)
        case .results(let results):
            showResultsViewState(results)
        }
    }
    
    private func showEmptyViewState() {
        setBackground(placeholderView())
        setResults([], animated: true)
    }
    
    private func showErrorViewState(_ error: String) {
        setBackground(errorView(error: error))
        setResults([], animated: true)
    }
    
    private func showResultsViewState(_ results: SearchResults) {
        if results.items.count == 0 {
            setBackground(emptyView(results: results))
        }
        else {
            setBackground(nil)
        }
        setResults(results.items, animated: true)
    }
    
    private func setResults(_ results: [SearchResultViewModel], animated: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResultViewModel>()
        if results.count > 0 {
            snapshot.appendSections([0])
            snapshot.appendItems(results, toSection: 0)
        }
        tableDataSource?.apply(snapshot, animatingDifferences: animated, completion: nil)
    }
    
    private func setBackground(_ view: UIView?) {
        dispatchPrecondition(condition: .onQueue(.main))
        backgroundView.contentView = view
//        backgroundView?.frame = tableView.bounds
//        tableView.backgroundView = backgroundView
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

    private func emptyView(results: SearchResults) -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.iconImage = UIImage(systemName: "list.bullet")
        view.caption = Localization.shared.formattedString(named: "search-empty %@", results.tags.joined(separator: ", "))
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
        guard let model = tableDataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        let viewController = QuestionViewController(model: model)
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
