//
//  SearchViewController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import UIKit
import Combine

import Layout


///
///
///
private class AnyState {
    weak var context: SearchViewController!
    func enter() {
        
    }
}


///
///
///
private final class PlaceholderState: AnyState {
    override func enter() {
        context.setBackground(placeholderView())
        context.setResults([], animated: true)
    }

    private func placeholderView() -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.caption = NSLocalizedString("search-placeholder", comment: "")
        view.iconImage = UIImage(systemName: "text.magnifyingglass")
        return view
    }
}


///
///
///
private final class SearchState: AnyState {
    private let query: String
    
    init(query: String) {
        self.query = query
    }
    
    override func enter() {
        if query.isEmpty == false {
            context.setBackground(activeView())
        }
        context.setResults([], animated: true)
        context.viewModel.search(query: query)
    }
    
    private func activeView() -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.caption = NSLocalizedString("search-activity", comment: "")
        view.activityIndicatorVisible = true
        return view
    }
}


///
///
///
private final class ErrorState: AnyState {
    private let error: String
    
    init(error: String) {
        self.error = error
    }
    
    override func enter() {
        context.setBackground(errorView(error: error))
        context.setResults([], animated: true)
    }
    
    private func errorView(error: String) -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.iconImage = UIImage(systemName: "wifi.exclamationmark")
        view.caption = error
        return view
    }
}


///
///
///
private final class EmptyState: AnyState {
    private let description: String
    
    init(description: String) {
        self.description = description
    }
    
    override func enter() {
        context.setBackground(emptyView(description: description))
        context.setResults([], animated: true)
    }

    private func emptyView(description: String) -> ContentPlaceholderView {
        let view = ContentPlaceholderView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.iconImage = UIImage(systemName: "list.bullet")
        view.caption = description
        return view
    }
}


///
///
///
private final class ResultsState: AnyState {
    private let results: SearchViewModel.Results
    
    init(results: SearchViewModel.Results) {
        self.results = results
    }
    
    override func enter() {
        context.setBackground(nil)
        context.setResults(results.items, animated: true)
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
    
    fileprivate let viewModel: SearchViewModel
    private var currentState: AnyState?
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
            containerView.translatesAutoresizingMaskIntoConstraints = false
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

        view.backgroundColor = UIColor(named: "TertiaryBackgroundColor")

        // Configure table view
        let cellIdentifier = "ResultCell"
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.backgroundColor = UIColor(named: "TertiaryBackgroundColor")
        tableView.autoresizesSubviews = true
//        tableView.insetsContentViewsToSafeArea = false
//        tableView.insetsLayoutMarginsFromSafeArea = false
//        tableView.contentInsetAdjustmentBehavior = .never
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
        setState(SearchState(query: query))
    }

    private func updateSearchStatus(status: SearchViewModel.Status?) {
        let state = makeState(status: status)
        setState(state)
    }

    private func makeState(status: SearchViewModel.Status?) -> AnyState {
        switch status {
        case .none:
            return PlaceholderState()
        case .error(let error):
            return ErrorState(error: error)
        case .noResults(let description):
            return EmptyState(description: description)
        case .results(let results):
            return ResultsState(results: results)
        }
    }
    
    private func setState(_ state: AnyState) {
        currentState = state
        currentState?.context = self
        currentState?.enter()
    }
    
    fileprivate func setResults(_ results: [SearchViewModel.Results.Item], animated: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchViewModel.Results.Item>()
        if results.count > 0 {
            snapshot.appendSections([0])
            snapshot.appendItems(results, toSection: 0)
        }
        tableDataSource?.apply(snapshot, animatingDifferences: animated, completion: nil)
    }
    
    fileprivate func setBackground(_ view: UIView?) {
        dispatchPrecondition(condition: .onQueue(.main))
        backgroundView.contentView = view
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
