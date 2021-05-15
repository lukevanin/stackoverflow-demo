//
//  StackOverflowQuestionsService.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import Foundation
import Combine

import Mock


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
        public let lastActivityDate: Timestamp
        public let creationDate: Timestamp
        public let contentLicense: String?
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
///
///
public final class MockQuestionsService: IQuestionsService {
    
    private let mock = Mock()
    private let response: QuestionsResponse?
    
    public init(response: QuestionsResponse? = nil) {
        self.response = response
    }
    
    public func getQuestions(_ request: QuestionsRequest) -> AnyPublisher<QuestionsResponse, Error> {
        Just(response ?? makeResponse(for: request))
            .setFailureType(to: Error.self)
            .delay(for: 0.25, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func makeResponse(for request: QuestionsRequest) -> QuestionsResponse {
        return QuestionsResponse(
            items: (0 ..< 40).map { i in
                QuestionsResponse.Item(
                    questionId: i,
                    tags: request.tagged,
                    owner: QuestionsResponse.Item.Owner(
                        userType: "unknown",
                        displayName: mock.word(),
                        userId: UInt64(mock.integer(min: 10_000, max: 50_000)),
                        profileImage: mock.imageURL(width: 50, height: 50),
                        reputation: mock.integer(min: 0, max: 100_000),
                        link: nil
                    ),
                    isAnswered: mock.boolean(probability: 0.2),
                    viewCount: mock.integer(min: 0, max: 10_000),
                    answerCount: mock.integer(min: 0, max: 100),
                    score: mock.integer(min: 0, max: 5_000),
                    lastActivityDate: Timestamp(Date()),
                    creationDate: Timestamp(mock.pastDate(min: 120, max: 86_400 * 1000)),
                    contentLicense: nil,
                    link: URL(string: "http://google.com")!,
                    title: mock.sentence(min: 5, max: 15),
                    body: mock.article(min: 1, max: 5)
                )
            }
        )
    }
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
