//
//  SearchViewModel.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit
import Combine


/// Provides human readable search results. Typically used by views for performing search queries and
/// displaying search results to the user.
///
/// Usage:
/// 1.Observe `results` to receive updates on the search status, including errors and search results.
/// 2. Call`search(query:)` method passing the tag to search for.
/// 3. Call `refresh()` to repeat the previously executed query.
final class SearchViewModel {

    struct Results {
        
        struct Item: Hashable, Identifiable {
            
            struct Owner: Hashable {
                let displayName: String
                let reputation: String?
                let profileImageURL: URL?
            }
            
            let id: String
            let title: String
            let owner: Owner
            let votes: String
            let answers: String
            let views: String
            let answered: Bool
            let askedDate: String
            let content: String
            let tags: String
        }

        let tags: [String]
        let items: [Item]
    }

    enum Status {
        case noResults(String)
        case results(Results)
        case error(String)
    }
    
    var results: AnyPublisher<Status?, Never> {
        internalResults.eraseToAnyPublisher()
    }
    
    private let internalResults = CurrentValueSubject<Status?, Never>(nil)
    private var resultsCancellable: AnyCancellable?
    private let model: SearchModel
    
    init(model: SearchModel) {
        self.model = model
        resultsCancellable = model.results
            .map { status in
                status.map { Status($0) }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                self.internalResults.send(value)
            }
    }
    
    /// Repeats the previous query.
    func refresh() {
        model.refresh()
    }
    
    /// Performs a search query using the provided tags.
    func search(query: String) -> Void {
        model.search(query: query)
    }
}

