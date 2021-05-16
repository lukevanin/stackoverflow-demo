//
//  CodableTransport.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import Foundation
import Combine


/// General purpose type-safe network interface, that can fetch any Codable conforming data type.
protocol ICodableTransport {
    func get<Output>(path: String, parameters: [URLQueryItem]?) -> AnyPublisher<Output, Error> where Output: Decodable
}


/// Transport for interacting with HTTP services that return data encoded using JSON.
final class JSONTransport: ICodableTransport {
    
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let session: URLSession
    
    init(baseURL: URL, decoder: JSONDecoder, session: URLSession) {
        self.decoder = decoder
        self.baseURL = baseURL
        self.session = session
    }
    
    /// Get data from the given path of the base URL using the provided query parameters. Returns the
    /// decoded output type.
    func get<Output>(path: String, parameters: [URLQueryItem]?) -> AnyPublisher<Output, Error> where Output : Decodable {
        let request = makeURL(path: path, parameters: parameters)
        return session
            .dataTaskPublisher(for: request)
            .tryMap(decodeResponse)
            .eraseToAnyPublisher()
    }

    /// Creates a URLRequest from a path fragment and URL query parameters.
    private func makeRequest(path: String, parameters: [URLQueryItem]?) -> URLRequest {
        #warning("TODO: Make cache policy and timeout configurable")
        return URLRequest(
            url: makeURL(path: path, parameters: parameters),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0
        )
    }

    /// Creates a URL from a given path fragment and URL parameters.
    private func makeURL(path: String, parameters: [URLQueryItem]?) -> URL {
        var components = URLComponents(string: baseURL.absoluteString)!
        components.path.append(path)
        components.queryItems = parameters
        return components.url!
    }
    
    /// Decodes a JSON encoded response into a given concrete type that conforms to Decodable.
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
