//
//  SearchViewModel.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit
import Combine


extension SearchViewModel.Status {
    init(_ status: SearchModel.Status) {
        let localization = Localization.shared
        switch status {
        case .error(let error):
            self = .error(error.localizedDescription)
            
        case .results(let results):
            if results.items.count > 0 {
                self = .results(SearchViewModel.Results(results))
            }
            else {
                let description = localization.formattedString(named: "search-empty %@", results.tags.joined(separator: ", "))
                self = .noResults(description)
            }
        }
    }
}


extension SearchViewModel.Results {
    init(_ results: SearchModel.Results) {
        self.tags = results.tags
        self.items = results.items.map { item in
            SearchViewModel.Results.Item(item)
        }
    }
}


extension SearchViewModel.Results.Item {
    init(_ item: SearchModel.Results.Item) {
        let localization = Localization.shared
        self.id = String(item.id)
        self.title = item.title.decodeHTMLEntities() ?? item.title
        self.votes = localization.formattedString(named: "vote-count %lld", item.votes)
        self.answers = localization.formattedString(named: "answer-count %lld", item.answers)
        self.views = localization.formattedString(named: "view-count %lld", item.views)
        self.askedDate = localization.formattedString(named: "asked-on %@ at %@", localization.formatDate(item.askedDate), localization.formatTime(item.askedDate))
        self.owner = SearchViewModel.Results.Item.Owner(item.owner)
        self.answered = item.answered
        self.content = item.content
        self.tags = item.tags.joined(separator: ", ")
    }
    
    func formattedBody() -> AnyPublisher<NSAttributedString, Never> {
        Future<NSAttributedString, Never> { completion in
            DispatchQueue.global(qos: .userInitiated).async {
                let data = content.data(using: .utf8)
                let content: NSAttributedString = data.flatMap { data -> NSAttributedString? in
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ]
                    return try? NSAttributedString(
                        data: data,
                        options: options,
                        documentAttributes: nil
                    )
                } ?? NSAttributedString(string: content)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                    .foregroundColor: UIColor(named: "PrimaryTextColor") as Any,
                ]
                let range = NSRange(location: 0, length: content.length)
                let output = NSMutableAttributedString(attributedString: content)
                output.setAttributes(attributes, range: range)
                completion(.success(output))
            }
        }
        .eraseToAnyPublisher()
    }
}


extension SearchViewModel.Results.Item.Owner {
    init(_ owner: SearchModel.Results.Item.Owner) {
        let localization = Localization.shared
        self.displayName = localization.formattedString(named: "asked-by %@", owner.displayName)
        self.reputation = owner.reputation.map { localization.formatInteger($0) }
        self.profileImageURL = owner.profileImageURL
    }
}


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
    
    func refresh() {
        model.refresh()
    }
    
    func search(query: String) -> Void {
        model.search(query: query)
    }
}

