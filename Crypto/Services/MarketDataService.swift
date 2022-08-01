//
//  MarketDataService.swift
//  Crypto
//
//  Created by Yurii on 23.07.2022.
//

import Combine
import Foundation

class MarketDataService {
    @Published var marketData: Market? = nil
    
    var marketDataSubscription: AnyCancellable?
    
    init() {
        getData()
    }
    
    private func getData() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else { return }
        
        marketDataSubscription = NetworkManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkManager.handleCompletion, receiveValue: { [weak self] returnedData in
                self?.marketData = returnedData.data
                self?.marketDataSubscription?.cancel()
            })
    }
}
