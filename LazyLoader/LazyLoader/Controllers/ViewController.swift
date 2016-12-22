//
//  ViewController.swift
//  LazyLoader
//
//  Created by Sachin Sawant on 22/12/16.
//  Copyright © 2016 Sachin Sawant. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK:- Properties
    var feedContent:Content = Content(title: "", images: [])
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fetchDataFromJSONFeed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK:- Helper Methods
    private func fetchDataFromJSONFeed() {
        ContentManager.getContentfromJSONFeed(urlString: Config.feedURL) { (success, content) in
            
            // Show alert to user on failure
            if(!success || content == nil) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Unable to fetch data", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            guard let content = content else {
                return
            }
        
            // Success
            self.feedContent = content
            
            DispatchQueue.main.async {
                self.title = content.title
            }
        }
    }

}

