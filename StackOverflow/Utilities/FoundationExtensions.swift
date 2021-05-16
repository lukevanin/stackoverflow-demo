//
//  FoundationExtensions.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import Foundation

extension String {

    /// Convert HTML encoded entities (e.g. &quot;) to UTF8.
    /// See: https://stackoverflow.com/a/25607542/762377
    func decodeHTMLEntities() -> String? {

        guard let data = self.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        return attributedString.string
    }
}
