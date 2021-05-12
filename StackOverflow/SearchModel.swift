//
//  SearchModel.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import Foundation
import Combine


final class SearchModel: ISearchModel {
    
    var results: AnyPublisher<SearchResults, Never>  {
        internalResults.eraseToAnyPublisher()
    }
    
    private let internalResults = CurrentValueSubject<SearchResults, Never>(.empty)
    
    func search(query: String) {
        guard query.isEmpty == false else {
            internalResults.send(.empty)
            return
        }
        
        let items = (0 ..< 10).map { (i: Int) -> SearchResultViewModel in
            SearchResultViewModel(
                id: String(i),
                title: "\(query) result \(i)",
                owner: "test",
                votes: i * 10,
                answers: i * 2,
                views: i * 1000,
                answered: i % 3 == 0
            )
        }

        internalResults.send(.results(items))
    }
}
