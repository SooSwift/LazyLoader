//
//  ContentManager.swift
//  LazyLoader
//
//  Created by Sachin Sawant on 22/12/16.
//  Copyright © 2016 Sachin Sawant. All rights reserved.
//

import Foundation

class ContentManager{
    
    // Fetch JSON Feed from Web
    class func getContentfromJSONFeed(urlString:String, completion:@escaping (_ success:Bool, _ jsonContent:Content?)->Void) {
        
        // Check for URL validaty
        guard let url = URL(string: urlString) else {
            print("Unable to create URL instance. Please check URL String")
            return
        }
        
        URLSession.shared.dataTask(with: url)
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Check for valid response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unable to receive response from URL \(urlString)")
                completion(false, nil)
                return
            }
            if(httpResponse.statusCode != 200) {
                print("Unexpected http status for URL: \(urlString)")
                completion(false, nil)
                return
            }
            guard error == nil else {
                print("Received error fetching data from URL: \(error)")
                completion(false, nil)
                return
            }
            guard let jsonData = data else {
                print("Failed to receive data")
                completion(false, nil)
                return
            }
            
            //INFO: This json feed is encoded with ISOLatin1. Convert it to UTF-8 before serialization to be successful
            guard let latinEncodedString = String(data: jsonData, encoding: String.Encoding.isoLatin1) else {
                print("Expecting ISOLatin1 encoded data but found otherwize")
                completion(false, nil)
                return
            }
            guard let utf8Data = latinEncodedString.data(using: String.Encoding.utf8) else {
                print("Expecting ISOLatin1 encoded data but found otherwize")
                completion(false, nil)
                return
            }
            
            // Serialize JSON
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: utf8Data, options: []) as? [String:AnyObject]else {
                    print("Failed to parse json data")
                    completion(false, nil)
                    return
                }
                
                // Parse JSON
                guard let parsedContent = self.parseContentFrom(json: jsonObject) else {
                    print("Failed to parse JSON. Invalid JSON")
                    completion(false, nil)
                    return
                }
                
                completion(true, parsedContent)
            }
            catch {
                print("Failed to parse json data with error: \(error)")
                completion(false, nil)
                return
            }
        }
        
        dataTask.resume()
    }
    
    // Parse JSON
    private class func parseContentFrom(json jsonObject:[String:AnyObject]) -> Content? {
        guard let title = jsonObject["title"] as? String else {
            return nil
        }
        
        guard let imageArray = jsonObject["rows"] as? [AnyObject] else {
            return nil
        }
        
        var images = [ImageElement]()
        for imageDictionary in imageArray {
            guard let imageElement = imageDictionary as? [String:AnyObject] else {
                continue
            }
            
            let imageName = imageElement["title"] as? String ?? "UNKNOWN"
            let imageDescription = imageElement["description"] as? String ?? ""
            let imageHref = imageElement["imageHref"] as? String ?? ""
        
            let image = ImageElement(name: imageName, description: imageDescription, imageURL: imageHref)
            images.append(image)
        }
        
        return Content(title: title, images: images)
    }
}
