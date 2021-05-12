//
//  StackOverflowQuestionsService.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import Foundation
import Combine


public struct QuestionsRequest: Codable {
    
    public enum Order: String, Codable {
        case ascending = "asc"
        case descending = "desc"
    }
    
    public enum Sort: String, Codable {
        case activity // last_activity_date
        case creation // creation_date
        case votes // score
        case hot // by the formula ordering the hot tab
        case week // by the formula ordering the week tab
        case month // by the formula ordering the month tab
    }
    
    public enum Filter: String, Codable {
        case withBody = "withBody"
    }
    
    public var pageSize: Int = 20
    public var order: Order = .descending
    public var sort: Sort = .activity
    public var tagged: [String] = []
    public var site: String = "stackoverflow"
    public var filter: Filter = .withBody
    
    public init() {
        
    }
}


public struct QuestionsResponse: Decodable {
    
    public struct Item: Decodable {

        public struct Owner: Decodable {
            public let userType: String
            public let displayName: String
            public let userId: UInt64?
            public let profileImage: URL?
            public let reputation: Int?
            public let link: URL?
        }

        public let questionId: UInt64
        public let tags: [String]
        public let owner: Owner
        public let isAnswered: Bool
        public let viewCount: Int
        public let answerCount: Int
        public let score: Int
        public let lastActivityDate: UInt64
        public let creationDate: UInt64
        public let contentLicense: String
        public let link: URL
        public let title: String
        public let body: String
    }
    
    public let items: [Item]
}


public protocol IQuestionsService {
    func getQuestions(_ request: QuestionsRequest) -> AnyPublisher<QuestionsResponse, Error>
}


///
/// https://api.stackexchange.com/docs/questions
///
public final class QuestionsService: IQuestionsService {
    
    private let transport: ICodableTransport
    
    public init(baseURL: URL, session: URLSession) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.transport = JSONTransport(
            baseURL: baseURL,
            decoder: decoder,
            session: session
        )
    }
    
    public func getQuestions(_ request: QuestionsRequest) -> AnyPublisher<QuestionsResponse, Error> {
        var parameters = [URLQueryItem]()
        parameters.append(URLQueryItem(name: "pageSize", value: String(request.pageSize)))
        parameters.append(URLQueryItem(name: "order", value: request.order.rawValue))
        parameters.append(URLQueryItem(name: "sort", value: request.sort.rawValue))
        parameters.append(URLQueryItem(name: "tagged", value: request.tagged.joined(separator: ";")))
        parameters.append(URLQueryItem(name: "site", value: request.site))
        parameters.append(URLQueryItem(name: "filter", value: request.filter.rawValue))
        return transport.get(
            path: "questions",
            parameters: parameters
        )
    }
}
