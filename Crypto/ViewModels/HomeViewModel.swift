//
//  HomeViewModel.swift
//  Crypto
//
//  Created by Yurii on 21.07.2022.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    @Published var allCoins = [Coin]()
    @Published var portfolioCoins = [Coin]()
    
    @Published var statistics = [
        Statistics(title: "Title", value: "Value", percentageChange: 1),
        Statistics(title: "Title", value: "Value", percentageChange: nil),
        Statistics(title: "Title", value: "Value", percentageChange: nil),
        Statistics(title: "Title", value: "Value", percentageChange: -7)
    ]
    
    @Published var searchText = ""
    @Published var selectedCoin: Coin? = nil
    @Published var showingPortfolio = false
    @Published var showingSheet = false
    @Published var showingDetailView = false
    @Published var sortOption: SortOption = .holdings
    
    enum SortOption {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
        
    }
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func segue(coin: Coin) {
        selectedCoin = coin
        showingDetailView.toggle()
    }
    
    func addSubscribers() {
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
        
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] returnedStats in
                self?.statistics = returnedStats
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: Coin, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    private func filterAndSortCoins(text: String, coins: [Coin], sort: SortOption) -> [Coin] {
        var updatedCoins = filterCoins(text: text, coins: coins)
        sortCoins(coins: &updatedCoins, sort: sort)
        return updatedCoins
    }
    
    private func filterCoins(text: String, coins: [Coin]) -> [Coin] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { coin -> Bool in
            return coin.name.lowercased().contains(lowercasedText) || coin.symbol.lowercased().contains(lowercasedText) || coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    private func sortCoins(coins: inout [Coin], sort: SortOption) {
        switch sort {
        case .rank, .holdings:
            coins.sort(by: { $0.rank < $1.rank })
        case .rankReversed, .holdingsReversed:
            coins.sort(by: { $0.rank > $1.rank })
        case .price:
            coins.sort(by: { $0.currentPrice < $1.currentPrice })
        case .priceReversed:
            coins.sort(by: { $0.currentPrice > $1.currentPrice })
        }
    }
    
    private func sortPortfolioCoinsIfNeeded(coins: [Coin]) -> [Coin] {
        switch sortOption {
        case .holdings:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
        case .holdingsReversed:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
        default:
            return coins
        }
    }
    
    private func mapAllCoinsToPortfolioCoins(allCoins: [Coin], portfolioEntities: [Portfolio]) -> [Coin] {
        allCoins.compactMap { coin -> Coin? in
            guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else { return nil }
            return coin.updateHoldings(amount: entity.amount)
        }
    }
    
    private func mapGlobalMarketData(market: Market?, portfolioCoins: [Coin]) -> [Statistics] {
        var stats = [Statistics]()
        
        guard let data = market else { return stats }
        
        let marketCap = Statistics(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = Statistics(title: "24h Volume", value: data.volume, percentageChange: nil)
        let btcDominance = Statistics(title: "BTC Dominance", value: data.btcDominance, percentageChange: nil)
        
        let portfolioValue = portfolioCoins
                                .map(\.currentHoldingsValue)
                                .reduce(0, +)
        
        let previousValue = portfolioCoins
                                .map { coin -> Double in
                                    let currentValue = coin.currentHoldingsValue
                                    let percentChange = coin.priceChangePercentage24H! / 100
                                    let previousValue = currentValue / (1 + percentChange)
                                    return previousValue
                                }
                                .reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        let portfolio = Statistics(title: "Portfolio Value", value: portfolioValue.asCurrencyWith2Decimals(), percentageChange: percentageChange)
        
        stats.append(contentsOf: [marketCap, volume, btcDominance, portfolio])
        return stats
    }
}
