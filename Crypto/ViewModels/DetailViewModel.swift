//
//  DetailViewModel.swift
//  Crypto
//
//  Created by Yurii on 26.07.2022.
//

import Combine
import Foundation

class DetailViewModel: ObservableObject {
    @Published var overviewStats = [Statistics]()
    @Published var additionalStats = [Statistics]()
    @Published var coin: Coin
    
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    
    private let detailDataService: DetailDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: Coin) {
        self.coin = coin
        self.detailDataService = DetailDataService(coin: coin)
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        detailDataService.$details
            .combineLatest($coin)
            .map(mapData)
            .sink { [weak self] stats in
                self?.overviewStats = stats.overview
                self?.additionalStats = stats.additional
            }
            .store(in: &cancellables)
        
        detailDataService.$details
            .sink { [weak self] returnedDetails in
                self?.coinDescription = returnedDetails?.readableDescription
                self?.websiteURL = returnedDetails?.links?.homepage?.first
                self?.redditURL = returnedDetails?.links?.subredditURL
            }
            .store(in: &cancellables)
    }
    
    private func mapData(detail: Detail?, coin: Coin) -> (overview: [Statistics], additional: [Statistics]) {
        // overview
        let price = coin.currentPrice.asCurrencyWith6Decimals()
        let priceChange = coin.priceChangePercentage24H
        let priceStat = Statistics(title: "Current price", value: price, percentageChange: priceChange)
        
        let marketCap = "$" + (coin.marketCap?.formattedWithAbbreviations() ?? "")
        let marketChange = coin.marketCapChangePercentage24H
        let marketStat = Statistics(title: "Market Capitalization", value: marketCap, percentageChange: marketChange)
        
        let rank = "\(coin.rank)"
        let rankStat = Statistics(title: "Rank", value: rank, percentageChange: nil)
        
        let volume = "$" + (coin.totalVolume?.formattedWithAbbreviations() ?? "")
        let volumeStat = Statistics(title: "Volume", value: volume, percentageChange: nil)
        
        let overviewArr = [priceStat, marketStat, rankStat, volumeStat]
        
        // additional
        let high = coin.high24H?.asCurrencyWith6Decimals() ?? "N/A"
        let highStat = Statistics(title: "24h High", value: high, percentageChange: nil)
        
        let low = coin.low24H?.asCurrencyWith6Decimals() ?? "N/A"
        let lowStat = Statistics(title: "24h Low", value: low, percentageChange: nil)
        
        let price24 = coin.priceChange24H?.asCurrencyWith6Decimals() ?? "N/A"
        let percentChange24 = coin.priceChangePercentage24H
        let priceChangeStat24 = Statistics(title: "24h Price Change", value: price24, percentageChange: percentChange24)
        
        let marketCap24 = "$" + (coin.marketCapChange24H?.formattedWithAbbreviations() ?? "")
        let marketCapPercent24 = coin.marketCapChangePercentage24H
        let marketCapStat24 = Statistics(title: "24h Market Cap Change", value: marketCap24, percentageChange: marketCapPercent24)
        
        let blockTime = detail?.blockTimeInMinutes ?? 0
        let blockTimeStr = blockTime == 0 ? "N/A" : "\(blockTime)"
        let blockStat = Statistics(title: "Block Time", value: blockTimeStr, percentageChange: nil)
        
        let hashing = detail?.hashingAlgorithm ?? "N/A"
        let hashingStat = Statistics(title: "Hashing Algorithm", value: hashing, percentageChange: nil)
        
        let additionalArr = [highStat, lowStat, priceChangeStat24, marketCapStat24, blockStat, hashingStat]
        
        
        return (overviewArr, additionalArr)
    }
}
