//
//  Extensions.swift
//  StackOverflowAPI
//
//  Created by Luke Van In on 2021/05/14.
//

import Foundation


public extension Date {
    /// Converts a timestamp to a date.
    init(_ timestamp: Timestamp) {
        self.init(
            timeIntervalSince1970: TimeInterval(timestamp.unixTimestamp) / 1000
        )
    }
}


/// Represents a unix timestamp (milliseconds since midnight 1 January 1970). Used by the StackOverflow
/// web service API to represent dates.
public struct Timestamp {
    /// Milliseconds since 01-01-1970  00:00 UTC
    public let unixTimestamp: Int64
    
    public init(unixTimestamp: Int64) {
        self.unixTimestamp = unixTimestamp
    }
    
    /// Converts a date to timestamp.
    public init(_ date: Date) {
        self.unixTimestamp = Int64(round(date.timeIntervalSince1970 * 1000))
    }
}

extension Timestamp: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.unixTimestamp = try container.decode(Int64.self)
    }
}
