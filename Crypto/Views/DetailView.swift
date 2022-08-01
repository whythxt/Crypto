//
//  DetailView.swift
//  Crypto
//
//  Created by Yurii on 26.07.2022.
//

import SwiftUI

struct DetailLoadingView: View {
    @Binding var coin: Coin?
    
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(coin: coin)
            }
        }
    }
}

struct DetailView: View {
    @StateObject var vm: DetailViewModel
    
    @State private var showingDescription = false
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(coin: Coin) {
        _vm = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ChartView(coin: vm.coin)
                    .padding(.vertical)
                
                Text("Overview")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                ZStack {
                    if let coinDescription = vm.coinDescription, !coinDescription.isEmpty {
                        VStack(alignment: .leading) {
                            Text(coinDescription)
                                .font(.callout)
                                .foregroundColor(Color.theme.secondaryText)
                                .lineLimit(showingDescription ? nil : 3)
                            
                            Button {
                                withAnimation(.easeInOut) {
                                    showingDescription.toggle()
                                }
                            } label: {
                                Text(showingDescription ? "Less" : "Read more")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.vertical, 3)
                            }
                            .tint(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                    ForEach(vm.overviewStats) { stat in
                        StatisticsView(stat: stat)
                    }
                }
                
                Text("Additional Details")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                    ForEach(vm.additionalStats) { stat in
                        StatisticsView(stat: stat)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    if let website = vm.websiteURL, let url = URL(string: website) {
                        Link("Website", destination: url)
                    }
                    
                    if let reddit = vm.redditURL, let url = URL(string: reddit) {
                        Link("Reddit", destination: url)
                    }
                }
                .tint(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
            }
            .padding()
        }
        .navigationTitle(vm.coin.name)
        .toolbar {
            HStack {
                Text(vm.coin.symbol.uppercased())
                    .font(.headline)
                    .foregroundColor(Color.theme.secondaryText)
                
                CoinImageView(coin: vm.coin)
                    .frame(width: 25, height: 25)
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(coin: dev.coin)
        }
    }
}
