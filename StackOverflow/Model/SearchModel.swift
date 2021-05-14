//
//  SearchModel.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import Foundation
import Combine

import StackOverflowAPI


private class AnyState {
    weak var context: SearchModel!
    
    func enter() {
    }
    
    func search(query: String) {
    }
    
    func refresh() {
    }
}


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
        context.setState(SearchState(query: query))
    }
}


private final class SearchState: AnyState {
    
    private var requestCancellable: AnyCancellable?
    private let query: String
    
    init(query: String) {
        self.query = query
    }
    
    override func enter() {
        dispatchPrecondition(condition: .onQueue(.main))
        let maximumResults = context.configuration.maximumResults
        let tags = [query]
        var request = QuestionsRequest()
        request.pageSize = maximumResults
        request.tagged = tags
        requestCancellable = context.service
            .getQuestions(request)
            .map { response -> SearchModel.Status in
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
                Just(.error(error))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self else {
                    return
                }
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


final class SearchModel {
    
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
    
    enum Status {
        case results(Results)
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
    
    func refresh() {
        currentState?.refresh()
    }
    
    func search(query: String) {
        currentState?.search(query: query)
    }
    
    fileprivate func setState(_ state: AnyState) {
        dispatchPrecondition(condition: .onQueue(.main))
        currentState = state
        currentState?.context = self
        currentState?.enter()
    }
}
