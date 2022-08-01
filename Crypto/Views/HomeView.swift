//
//  HomeView.swift
//  Crypto
//
//  Created by Yurii on 21.07.2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: HomeViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        CircleButtonView(icon: "plus")
                            .animation(nil, value: UUID())
                            .background(
                                CircleButtonAnimationView(isAnimating: $vm.showingPortfolio)
                            )
                            .onTapGesture {
                                if vm.showingPortfolio {
                                    vm.showingSheet.toggle()
                                }
                            }
                            .opacity(vm.showingPortfolio ? 1.0 : 0.0)
                        
                        Spacer()
                        
                        Text(vm.showingPortfolio ? "Portfolio" : "Live Prices")
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundColor(Color.theme.accent)
                            .animation(nil, value: UUID())
                        
                        Spacer()
                        
                        CircleButtonView(icon: "chevron.right")
                            .rotationEffect(Angle(degrees: vm.showingPortfolio ? 180 : 0))
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    vm.showingPortfolio.toggle()
                                }
                            }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        ForEach(vm.statistics) { stat in
                            StatisticsView(stat: stat)
                                .frame(width: UIScreen.main.bounds.width / 3)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, alignment: vm.showingPortfolio ? .trailing : .leading)
                    
                    SearchBarView(searchText: $vm.searchText)
                    
                    HStack {
                        HStack(spacing: 3) {
                            Text("Coin")
                            Image(systemName: "chevron.down")
                                .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed ? 1.0 : 0.0))
                                .rotation3DEffect(Angle.degrees(vm.sortOption == .rank ? 0 : 180), axis: (x:1, y:0, z:0))
                        }
                        .onTapGesture {
                            withAnimation(.default) {
                                vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("Holdings")
                            Image(systemName: "chevron.down")
                                .opacity((vm.sortOption == .holdings || vm.sortOption == .holdingsReversed ? 1.0 : 0.0))
                                .rotation3DEffect(Angle.degrees(vm.sortOption == .holdings ? 0 : 180), axis: (x:1, y:0, z:0))
                        }
                        .opacity(vm.showingPortfolio ? 1 : 0)
                        .onTapGesture {
                            withAnimation(.default) {
                                vm.sortOption = vm.sortOption == .holdings ? .holdingsReversed : .holdings
                            }
                        }
                        
                        HStack(spacing: 3) {
                            Text("Price")
                            Image(systemName: "chevron.down")
                                .opacity((vm.sortOption == .price || vm.sortOption == .priceReversed ? 1.0 : 0.0))
                                .rotation3DEffect(Angle.degrees(vm.sortOption == .price ? 0 : 180), axis: (x:1, y:0, z:0))
                        }
                        .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
                        .onTapGesture {
                            withAnimation(.default) {
                                vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                    .padding(.horizontal)
                    
                    if !vm.showingPortfolio {
                        List {
                            ForEach(vm.allCoins) { coin in
                                CoinRowView(coin: coin, showingHoldings: false)
                                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                                    .onTapGesture {
                                        vm.segue(coin: coin)
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .transition(.move(edge: .leading))
                    } else {
                        List {
                            ForEach(vm.portfolioCoins) { coin in
                                CoinRowView(coin: coin, showingHoldings: true)
                                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                                    .onTapGesture {
                                        vm.segue(coin: coin)
                                    }
                                    .contextMenu {
                                        Button("Delete", role: .destructive) {
                                            vm.updatePortfolio(coin: coin, amount: 0)
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .transition(.move(edge: .trailing))
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $vm.showingSheet) {
                PortfolioView()
                    .environmentObject(vm)
            }
            .refreshable {
                vm.addSubscribers()
            }
            .background(
                NavigationLink(
                    destination: DetailLoadingView(coin: $vm.selectedCoin),
                    isActive: $vm.showingDetailView,
                    label: { EmptyView() }
                )
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(dev.homeVM)
    }
}
