//
//  CodableTransport.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import Foundation
import Combine

protocol ICodableTransport {
    func get<Output>(path: String, parameters: [URLQueryItem]?) -> AnyPublisher<Output, Error> where Output: Decodable
}

final class JSONTransport: ICodableTransport {
    
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let session: URLSession
    
    init(baseURL: URL, decoder: JSONDecoder, session: URLSession) {
        self.decoder = decoder
        self.baseURL = baseURL
        self.session = session
    }
    
    func get<Output>(path: String, parameters: [URLQueryItem]?) -> AnyPublisher<Output, Error> where Output : Decodable {
        let request = makeURL(path: path, parameters: parameters)
        return session
            .dataTaskPublisher(for: request)
            .tryMap(decodeResponse)
            .eraseToAnyPublisher()
    }

    private func makeRequest(path: String, parameters: [URLQueryItem]?) -> URLRequest {
        return URLRequest(
            url: makeURL(path: path, parameters: parameters),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0
        )
    }

    private func makeURL(path: String, parameters: [URLQueryItem]?) -> URL {
        var components = URLComponents(string: baseURL.absoluteString)!
        components.path.append(path)
        components.queryItems = parameters
        return components.url!
    }
    
    private func decodeResponse<T>(data: Data, response: URLResponse) throws -> T where T : Decodable {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }
        let output = try decoder.decode(T.self, from: data)
        return output
    }
}
