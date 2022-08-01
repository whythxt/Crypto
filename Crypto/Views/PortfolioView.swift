//
//  PortfolioView.swift
//  Crypto
//
//  Created by Yurii on 24.07.2022.
//

import SwiftUI

struct PortfolioView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var vm: HomeViewModel
    
    @State private var selectedCoin: Coin? = nil
    @State private var quantity = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $vm.searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins) { coin in
                                CoinLogoView(coin: coin)
                                    .frame(width: 75)
                                    .padding(3)
                                    .onTapGesture {
                                        withAnimation(.easeIn) {
                                            updateSelectedCoin(coin: coin)
                                        }
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedCoin?.id  == coin.id ? Color.theme.green : Color.clear, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        selectedCoin = coin
                                    }
                            }
                        }
                        .frame(height: 120)
                        .padding(.leading, 5)
                    }
                    
                    if selectedCoin != nil {
                        VStack(spacing: 20) {
                            HStack {
                                Text("Current price of \(selectedCoin?.symbol.uppercased() ?? "")")
                                Spacer()
                                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Amount in your portfolio: ")
                                Spacer()
                                TextField("Enter your amount", text: $quantity)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Current value")
                                Spacer()
                                Text(getCurrentValue().asCurrencyWith2Decimals())
                            }
                        }
                        .padding()
                        .font(.headline)
                        .animation(nil, value: UUID())
                    }
                }
            }
            .navigationTitle("Edit Portfolio")
            .onChange(of: vm.searchText, perform: { val in
                if val == "" {
                    removeSelection()
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantity.replacingOccurrences(of: ",", with: ".")) ? false : true)
                }
            }
        }
    }
    
    private func updateSelectedCoin(coin: Coin) {
        selectedCoin = coin
        
        if let portfolioCoin = vm.portfolioCoins.first(where: { $0.id == coin.id }),
           let amount = portfolioCoin.currentHoldings {
            quantity = String(amount)
        } else {
            quantity = ""
        }
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(quantity.replacingOccurrences(of: ",", with: ".")) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        
        return 0
    }
    
    private func save() {
        guard let coin = selectedCoin, let amount = Double(quantity.replacingOccurrences(of: ",", with: ".")) else { return }
        
        vm.updatePortfolio(coin: coin, amount: amount)

        removeSelection()
        UIApplication.shared.endEditing()
        dismiss()
        
    }
    
    private func removeSelection() {
        selectedCoin = nil
        vm.searchText = ""
        quantity = ""
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM)
    }
}
