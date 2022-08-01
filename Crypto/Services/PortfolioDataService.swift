//
//  PortfolioDataService.swift
//  Crypto
//
//  Created by Yurii on 25.07.2022.
//

import CoreData
import Foundation

class PortfolioDataService {
    private let container: NSPersistentContainer
    
    private let containerName = "PortfolioContainer"
    private let entityName = "Portfolio"
    
    @Published var savedEntities = [Portfolio]()
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            self.getPortfolio()
        }
    }
    
    func updatePortfolio(coin: Coin, amount: Double) {
        if let entity = savedEntities.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                remove(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
        }
    }
    
    private func getPortfolio() {
        let request = NSFetchRequest<Portfolio>(entityName: entityName)
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func add(coin: Coin, amount: Double) {
        let entity = Portfolio(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        
        applyChanges()
    }
    
    private func update(entity: Portfolio, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func remove(entity: Portfolio) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func applyChanges() {
        save()
        getPortfolio()
    }
}
