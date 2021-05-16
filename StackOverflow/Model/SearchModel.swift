//
//  SearchModel.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import Foundation
import Combine

import StackOverflowAPI


// MARK: - Search Model States


/// Base class for search model state. Refer to individual state implementations below for details.
private class AnyState {
    weak var context: SearchModel!
    
    func enter() {
    }
    
    func search(query: String) {
    }
    
    func refresh() {
    }
}


/// Empty state. Initial state for the model, before a search has been executed.
private final class EmptyState: AnyState {
    
    override func enter() {
        context.internalResults.send(nil)
    }
    
    override func search(query: String) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard query.isEmpty == false else {
            // Query is empty. Don't do anything.
            return
        }
        // Query is non-empty. Perform the search.
        context.setState(SearchState(query: query))
    }
}


/// Search State. Executes a query and returns the results.
private final class SearchState: AnyState {
    
    private var requestCancellable: AnyCancellable?
    private let query: String
    
    init(query: String) {
        self.query = query
    }
    
    override func enter() {
        dispatchPrecondition(condition: .onQueue(.main))
        
        // Create the request using the maximum number of results, and query.
        let maximumResults = context.configuration.maximumResults
        let tags = [query]
        var request = QuestionsRequest()
        request.pageSize = maximumResults
        request.tagged = tags
        
        // Call the service method to run the query, then wait for the response.
        // Keep a reference to the asynchronous cancellable so that it stays
        // allocated when this method returns.
        requestCancellable = context.service
            .getQuestions(request)
            .map { response -> SearchModel.Status in
                // Convert the web service result to the model structure. 
                let items = response
                    .items
                    .map { item in
                        SearchModel.Results.Item(
                            id: String(item.questionId),
                            title: item.title,
                            owner: SearchModel.Results.Item.Owner(
                                displayName: item.owner.displayName,
                                reputation: item.owner.reputation,
                                profileImageURL: item.owner.profileImage
                            ),
                            votes: item.score,
                            answers: item.answerCount,
                            views: item.viewCount,
                            answered: item.isAnswered,
                            askedDate: Date(item.creationDate),
                            content: item.body,
                            tags: item.tags
                        )
                    }
                    .prefix(maximumResults)
                let results = SearchModel.Results(
                    tags: tags,
                    items: Array(items)
                )
                return SearchModel.Status.results(results)
            }
            .catch { error in
                // Catch and convert errors to a search status.
                Just(.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self else {
                    return
                }
                // We're done. Go to the output state.
                self.context.setState(OutputState(query: self.query, results: results))
            }
    }
    
    override func search(query: String) {
        dispatchPrecondition(condition: .onQueue(.main))
        if query.isEmpty {
            // Query is empty. Discard the current query and go to the ready
            // state
            context.setState(EmptyState())
        }
        else if query != self.query {
            // Query is non-empty, and different to the current query. Discard
            // the current query and submit the new query.
            context.setState(SearchState(query: query))
        }
    }
}


/// Output state. Outputs the results of the search query.
private final class OutputState: AnyState {
    
    private let query: String
    private let results: SearchModel.Status
    
    init(query: String, results: SearchModel.Status) {
        self.query = query
        self.results = results
    }
    
    override func enter() {
        context.internalResults.send(results)
    }
    
    override func search(query: String) {
        if query.isEmpty {
            context.setState(EmptyState())
        }
        else {
            context.setState(SearchState(query: query))
        }
    }
    
    override func refresh() {
        context.setState(SearchState(query: query))
    }
}


// MARK: - Search Model


/// Used for searching for questions on StackOverflow.
///
/// Implemented using a finite state machine.
///
/// The following states are used:
///
/// **EmptyState:**
/// No results are available. Default state before a query is executed. The app displays a placeholder
/// message when the model is in the empty state.
///
/// **SearchState:**
/// A query is being executed. The model will transition to the output state once the query completes. The app
/// should display a progress indicator while the model is in the search state.
///
/// **OutputState:**
/// The query is complete. The model may transition to the search state if another query is executed. The app
/// should display the results of the query (list of items or an error).
///
/// Usage:
/// 1. Instantiate the `SearchModel` passing a configuration and service instance.
/// 2. Observe the `results` publisher to receive new search results.
/// 3. Call `search(query:)` passing a list of tags to search for.
/// 4. Optionally call `refresh()` to repeat the previous query.
final class SearchModel {
    
    /// Entity representing the results of a seqrch query. Contains the list of tags from the query, and zero or
    /// more items matching the query.
    struct Results {
        
        struct Item: Hashable, Identifiable {
            
            struct Owner: Hashable {
                let displayName: String
                let reputation: Int?
                let profileImageURL: URL?
            }
            
            let id: String
            let title: String
            let owner: Owner
            let votes: Int
            let answers: Int
            let views: Int
            let answered: Bool
            let askedDate: Date
            let content: String
            let tags: [String]
        }
        
        let tags: [String]
        let items: [Item]
    }
    
    /// Output of a search query, which may be an error, or a list of results.
    enum Status {
        
        /// Successful query containing a valid result set.
        case results(Results)
        
        /// Failed query resulting in an error.
        case error(Error)
    }
    
    struct Configuration {
        var maximumResults: Int
    }
    
    var results: AnyPublisher<Status?, Never>  {
        internalResults.eraseToAnyPublisher()
    }
    
    fileprivate let internalResults = CurrentValueSubject<Status?, Never>(nil)
    fileprivate let configuration: Configuration
    fileprivate let service: IQuestionsService
    
    private var currentState: AnyState?
    
    init(configuration: Configuration, service: IQuestionsService) {
        self.configuration = configuration
        self.service = service
        setState(EmptyState())
    }

    /// Searches for questions matching the given query containing a tag to search for.
    func search(query: String) {
        currentState?.search(query: query)
    }

    /// Repeat the previous query.
    func refresh() {
        currentState?.refresh()
    }
    
    fileprivate func setState(_ state: AnyState) {
        dispatchPrecondition(condition: .onQueue(.main))
        currentState = state
        currentState?.context = self
        currentState?.enter()
    }
}
