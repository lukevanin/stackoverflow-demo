//
//  Mock.swift
//  StackOverflowAPI
//
//  Created by Luke Van In on 2021/05/14.
//

import Foundation


extension String {
    /// https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
    func capitalizedFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}


/// Helper methods for generating random data, e.g. for creating random data for simulating a database for
/// testing purposes.
public struct Mock {
    
    public init() {
        
    }
    
    /// Returns a random integer between the given minimum and maximum limits.
    public func integer(min: Int, max: Int) -> Int {
        precondition(max > min)
        let range = max - min
        return min + (Int(arc4random()) % range)
    }
    
    /// Returns a random floating point number between the given minimum and maximum limits.
    public func real(min: Double, max: Double) -> Double {
        precondition(max > min)
        let range = abs(max - min)
        let i = arc4random() % UInt32.max
        let t = Double(i) / Double(UInt32.max)
        return min + (range * t)
    }
    
    /// Returns a boolean value with a true value occuring randomly with approximately the given
    /// probability.
    public func boolean(probability: Double) -> Bool {
        let v = real(min: 0, max: 1)
        return v <= probability
    }
    
    /// Returns a random string of lowercase letters, between 1 and 20 characters in length.
    public func word() -> String {
        #warning("TODO: Use gaussian distribution for word length")
        let length = integer(min: 1, max: 20)
        let characters = (0 ..< length).map { _ -> Character in
            let ascii = 97 + integer(min: 0, max: 12)
            return Character(Unicode.Scalar(ascii)!)
        }
        return String(characters)
    }
    
    /// Returns a string of words with a random number of words between the given minimum and
    /// maximum limits. The first letter of the first word is capitalized. The string is terminated with a
    /// period/full-stop.
    public func sentence(min: Int, max: Int) -> String {
        #warning("TODO: Use gaussian distribution for number of words")
        let length = integer(min: min, max: max)
        return (0 ..< length)
            .map { _ in word() }
            .joined(separator: " ")
            .capitalizedFirstLetter()
            .appending(".")
    }
    
    /// Returns a random number of sentences between the given minimum and
    /// maximum limits.
    public func paragraph(min: Int, max: Int) -> String {
        let length = integer(min: min, max: max)
        return (0 ..< length)
            .map { _ in sentence(min: 5, max: 25) }
            .joined(separator: " ")
    }
    
    /// Returns a random number of paragraphs between the given minimum and maximum limits.
    public func article(min: Int, max: Int) -> String {
        let length = integer(min: min, max: max)
        return (0 ..< length)
            .map { _ in paragraph(min: 1, max: 7) }
            .joined(separator: "\n")
    }
    
    /// Returns a URL for a random image with the given dimensions.
    public func imageURL(width: Int, height: Int) -> URL {
        let id = integer(min: 0, max: 1000)
        return URL(string: "https://picsum.photos/id/\(id)/\(width)/\(height)")!
    }
    
    /// Returns a date in the past within the given limits.
    public func pastDate(min: TimeInterval, max: TimeInterval) -> Date {
        Date().addingTimeInterval(-real(min: min, max: max))
    }
}
