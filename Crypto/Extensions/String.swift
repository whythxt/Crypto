//
//  String.swift
//  Crypto
//
//  Created by Yurii on 21.07.2022.
//

import Foundation

extension String {
    var removingHTMLOccurances: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
