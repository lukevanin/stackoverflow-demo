//
//  SearchViewModel+SearchModel.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/15.
//
//  Helper methods for converting search model classes to search view model.
//  Performs localization and conversions needed to transform data into a form
//  that can be displayed to the user.
//

import Foundation
import Combine


extension SearchViewModel.Status {
    
    ///
    /// Converts a `SearchModel.Status` to a view model.
    ///
    init(_ status: SearchModel.Status) {
        let localization = Localization.shared
        switch status {
        
        case .error(let error):
            // An error occurred while performing a search query. Format the
            // error message.
            let description = localization.formattedString(
                named: "search-error %@", error.localizedDescription
            )
            self = .error(description)
            
        case .results(let results):
            if results.items.count > 0 {
                // The query returned a non-empty result. Return the results.
                self = .results(SearchViewModel.Results(results))
            }
            else {
                // The query returned an empty result. Return a message
                // indicating what happened.
                let description = localization.formattedString(
                    named: "search-empty %@", results.tags.joined(separator: ", ")
                )
                self = .noResults(description)
            }
        }
    }
}


extension SearchViewModel.Results {
    
    ///
    /// Converts a  `SearchModel.Results` to a view model.
    ///
    init(_ results: SearchModel.Results) {
        self.tags = results.tags
        self.items = results.items.map { item in
            SearchViewModel.Results.Item(item)
        }
    }
}


extension SearchViewModel.Results.Item {
    
    ///
    /// Converts a `SearchModel.Results.Item` to a view model.
    ///
    init(_ item: SearchModel.Results.Item) {
        let localization = Localization.shared
        self.id = String(item.id)
        self.title = item.title.decodeHTMLEntities() ?? item.title
        self.votes = localization.formattedString(
            named: "vote-count %lld", item.votes
        )
        self.answers = localization.formattedString(
            named: "answer-count %lld", item.answers
        )
        self.views = localization.formattedString(
            named: "view-count %lld", item.views
        )
        self.askedDate = localization.formattedString(
            named: "asked-on %@ at %@",
            localization.formatDate(item.askedDate),
            localization.formatTime(item.askedDate)
        )
        self.owner = SearchViewModel.Results.Item.Owner(item.owner)
        self.answered = item.answered
        self.content = item.content
        self.tags = item.tags.joined(separator: ", ")
    }
}


extension SearchViewModel.Results.Item.Owner {
    
    ///
    /// Converts a `SearchModel.Results.Item.Owner` to a view model.
    ///
    init(_ owner: SearchModel.Results.Item.Owner) {
        let localization = Localization.shared
        self.displayName = localization.formattedString(
            named: "asked-by %@", owner.displayName
        )
        self.reputation = owner.reputation.map {
            localization.formatInteger($0)
        }
        self.profileImageURL = owner.profileImageURL
    }
}
