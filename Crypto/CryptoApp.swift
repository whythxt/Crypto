//
//  CryptoApp.swift
//  Crypto
//
//  Created by Yurii on 21.07.2022.
//

import SwiftUI

@main
struct CryptoApp: App {
    @StateObject private var vm = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(vm)
        }
    }
}
