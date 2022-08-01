//
//  Statistics.swift
//  Crypto
//
//  Created by Yurii on 22.07.2022.
//

import Foundation

struct Statistics: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let percentageChange: Double?
}
