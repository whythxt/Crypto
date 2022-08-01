//
//  CoinDataService.swift
//  Crypto
//
//  Created by Yurii on 22.07.2022.
//

import Combine
import SwiftUI

class CoinImageService {
    @Published var image: UIImage? = nil
    
    private var imageSubscription: AnyCancellable?
    private let coin: Coin
    private let fileManager = LocalFileManager.instance
    private let folderName = "coin_images"
    private let imageName: String
    
    init(coin: Coin) {
        self.coin = coin
        self.imageName = coin.id
        getImage()
    }
    
    private func getImage() {
        if let savedImage = fileManager.getImage(imageName, folderName) {
            image = savedImage
        } else {
            downloadImage()
        }
    }
    
    private func downloadImage() {
        guard let url = URL(string: coin.image) else { return }
        
        imageSubscription = NetworkManager.download(url: url)
            .tryMap { (data) -> UIImage? in
                return UIImage(data: data)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkManager.handleCompletion, receiveValue: { [weak self] returnedImage in
                guard let self = self, let downloadedImage = returnedImage else { return }
                self.image = downloadedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(downloadedImage, self.imageName, self.folderName)
            })
    }
}
