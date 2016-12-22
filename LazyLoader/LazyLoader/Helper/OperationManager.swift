//
//  OperationManager.swift
//  LazyLoader
//
//  Created by Sachin Sawant on 22/12/16.
//  Copyright © 2016 Sachin Sawant. All rights reserved.
//

import Foundation
import UIKit

class OperationManager {
    
    //MARK:- Properties
    var operationQueue:OperationQueue
    var ongoingOperations = [IndexPath:Operation]()
    
    //MARK:- Initializer
    init() {
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 3 //load max 3 images concurrently
    }
    
    func reset() {
        self.operationQueue.cancelAllOperations()
        self.ongoingOperations = [IndexPath:Operation]()
    }
}

class LazyDownloader: Operation {
    
    //MARK:- Properties
    var target:ImageElement
    
    //MARK:- Initializer
    init(withImageElement image:ImageElement) {
        self.target = image
    }
    
    //MARK:- Operation Method
    override func main() {
        if(self.isCancelled) {return}
        
        if(self.target.status == .DownloadComplete) {
            print("Image is already downloaded for title:\(target.name)")
            return
        }
        
        print("Downloading image for title:\(target.name)")
        if(self.isCancelled) {return}
        
        guard let imageURL = URL(string: target.imageURL) else {
            print("Malformed url for title: \(target.name)")
            self.target.status = .DownloadFailed
            return
        }
        
        var imageData = Data()
        do {
            imageData = try Data(contentsOf: imageURL)
        }
        catch {
            print("Failed to dowload image-data for title: \(target.name)")
            self.target.status = .DownloadFailed
            return
        }
        
        guard let downloadedImage = UIImage(data: imageData) else {
            print("Failed to parse image for title: \(target.name)")
            self.target.status = .DownloadFailed
            return
        }
        
        if(self.isCancelled) {return}
        self.target.image = downloadedImage
        self.target.status = .DownloadComplete
    }
}
