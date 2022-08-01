//
//  DetailDataService.swift
//  Crypto
//
//  Created by Yurii on 26.07.2022.
//

import Combine
import Foundation

class DetailDataService {
    @Published var details: Detail? = nil
    
    let coin: Coin
    var detailSubscription: AnyCancellable?
    
    init(coin: Coin) {
        self.coin = coin
        getDetails()
    }
    
    private func getDetails() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else { return }
        
        detailSubscription = NetworkManager.download(url: url)
            .decode(type: Detail.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkManager.handleCompletion, receiveValue: { [weak self] returnedDetails in
                self?.details = returnedDetails
                self?.detailSubscription?.cancel()
            })
    }
}
