//
//  UIApplication.swift
//  Crypto
//
//  Created by Yurii on 21.07.2022.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
