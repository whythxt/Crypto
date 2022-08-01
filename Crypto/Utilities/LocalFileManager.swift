//
//  LocalFileManager.swift
//  Crypto
//
//  Created by Yurii on 22.07.2022.
//

import SwiftUI

class LocalFileManager {
    static let instance = LocalFileManager()
    
    private init() { }
    
    func saveImage(_ image: UIImage, _ imageName: String, _ folderName: String) {
        createFolder(folderName)
        
        guard let data = image.pngData(), let url = getURLForImage(imageName, folderName) else { return }
        
        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getImage(_ imageName: String, _ folderName: String) -> UIImage? {
        guard let url = getURLForImage(imageName, folderName), FileManager.default.fileExists(atPath: url.path) else { return nil }
        
        return UIImage(contentsOfFile: url.path)
    }
    
    private func createFolder(_ folderName: String) {
        guard let url = getURLForFolder(folderName) else { return }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getURLForFolder(_ folderName: String) -> URL? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        return url.appendingPathComponent(folderName)
    }
    
    private func getURLForImage(_ imageName: String, _ folderName: String) -> URL? {
        guard let folderURL = getURLForFolder(folderName) else { return nil }
        
        return folderURL.appendingPathComponent(imageName + ".png")
    }
}

