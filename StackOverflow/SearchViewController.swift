//
//  SearchViewController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import UIKit
import Combine


struct SearchResultViewModel: Hashable, Identifiable {
    let id: String
    let title: String
    let owner: String
    let votes: Int
    let answers: Int
    let views: Int
    let answered: Bool
}


enum SearchResults {
    case empty
    case results([SearchResultViewModel])
    case error(String)
}


protocol ISearchModel {
    var results: AnyPublisher<SearchResults, Never> { get }
    func search(query: String) -> Void
}


private let checkmarkImage = UIImage(systemName: "checkmark")


///
///
///
final class SearchPlaceholderView: UIView {
    
    var caption: String? {
        get {
            captionLabel.text
        }
        set {
            captionLabel.text = newValue
        }
    }
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemGray
        view.image = UIImage(systemName: "magnifyingglass")
        return view
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        let layout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
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
                constant: -32
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
            return layout
        }()
        let textLayout: UIStackView = {
            let layout = UIStackView(
                arrangedSubviews: [
                    titleLabel,
                    VerticalSpacerView(),
                    ownerLabel,
                ]
            )
            layout.translatesAutoresizingMaskIntoConstraints = false
            layout.axis = .vertical
            layout.spacing = 8
            layout.alignment = .leading
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
            layout.spacing = 8
            layout.alignment = .center
            return layout
        }()
        contentView.addSubview(contentLayout)
        NSLayoutConstraint.activate([
            answeredImageView.widthAnchor.constraint(
                equalToConstant: 20
            ),
            answeredImageView.widthAnchor.constraint(
                equalTo: answeredImageView.heightAnchor
            ),
            
            statsLayout.widthAnchor.constraint(equalToConstant: 100),
            
            contentLayout.leftAnchor .constraint(
                equalToSystemSpacingAfter: contentView.leftAnchor,
                multiplier: 1
            ),
            contentView.rightAnchor.constraint(
                equalToSystemSpacingAfter: contentLayout.rightAnchor,
                multiplier: 1
            ),
            contentLayout.topAnchor.constraint(
                equalToSystemSpacingBelow: contentView.topAnchor,
                multiplier: 1
            ),
            contentView.bottomAnchor.constraint(
                equalToSystemSpacingBelow: contentLayout.bottomAnchor,
                multiplier: 1
            ),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: SearchResultViewModel) {
        titleLabel.text = viewModel.title
        ownerLabel.text = String(format: NSLocalizedString("asked-by %@", comment: ""), viewModel.owner)
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
    
    private let placeholderView: SearchPlaceholderView
    private let searchController: UISearchController
    private let model: ISearchModel
    private var resultsCancellable: AnyCancellable?
    private var tableDataSource: UITableViewDiffableDataSource<Int, SearchResultViewModel>?

    init(model: ISearchModel) {
        self.placeholderView = SearchPlaceholderView(frame: .zero)
        self.searchController = UISearchController(searchResultsController: nil)
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.searchTextField.placeholder = NSLocalizedString("search-prompt", comment: "")
        searchController.searchBar.returnKeyType = .done
        
        searchController.searchBar.tintColor = .white
        
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.backgroundColor = .white
        searchTextField.leftView?.tintColor = UIColor.systemGray
        searchTextField.tintColor = UIColor(named: "ThemeColor")


        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
            
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false

        // Monitor when the search controller is presented and dismissed.
        searchController.delegate = self

        // Monitor when the search button is tapped, and start/end editing.
        searchController.searchBar.delegate = self
        
        // Configure table view
        let cellIdentifier = "ResultCell"
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        placeholderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeholderView.frame = tableView.bounds
        tableView.autoresizesSubviews = true
        tableView.backgroundView = placeholderView
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
    
    private func updateSearchResults(results: SearchResults) {
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
        placeholderView.isHidden = false
        placeholderView.caption = NSLocalizedString("search-placeholder", comment: "")
        setResults([], animated: true)
    }
    
    private func showErrorViewState(_ error: String) {
        
    }
    
    private func showResultsViewState(_ results: [SearchResultViewModel]) {
        placeholderView.isHidden = true
        setResults(results, animated: true)
    }
    
    private func setResults(_ results: [SearchResultViewModel], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResultViewModel>()
        if results.count > 0 {
            snapshot.appendSections([0])
            snapshot.appendItems(results, toSection: 0)
        }
        tableDataSource?.apply(snapshot, animatingDifferences: animated, completion: nil)
    }
    
    // UITableViewController
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // model.search(query: searchController.searchBar.text ?? "")
    }
}

extension SearchViewController: UISearchControllerDelegate {

}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        model.search(query: searchController.searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        model.search(query: "")
    }
}
