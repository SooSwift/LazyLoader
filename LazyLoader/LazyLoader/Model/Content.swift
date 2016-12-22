//
//  Content.swift
//  LazyLoader
//
//  Created by Sachin Sawant on 22/12/16.
//  Copyright © 2016 Sachin Sawant. All rights reserved.
//

import Foundation
import UIKit

// Status to track the download state for an image
enum DownloadStatus {
    case Default
    case DownloadComplete
    case DownloadFailed
}

// Image with relative data and state
class ImageElement {
    let name:String
    let description:String
    let imageURL:String
    var image:UIImage = #imageLiteral(resourceName: "placeholder")
    var status:DownloadStatus = DownloadStatus.Default
    
    init(name:String, description:String, imageURL:String) {
        self.name = name
        self.description = description
        self.imageURL = imageURL
    }
}

// Content fetched from web having title and image collection
class Content {
    var title = ""
    var images = [ImageElement]()
    
    init(title:String, images:[ImageElement]) {
        self.title = title
        self.images = images
    }
}
