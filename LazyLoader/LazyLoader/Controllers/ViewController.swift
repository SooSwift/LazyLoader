//
//  ViewController.swift
//  LazyLoader
//
//  Created by Sachin Sawant on 22/12/16.
//  Copyright © 2016 Sachin Sawant. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    //MARK:- Properties
    var feedContent:Content = Content(title: "", images: [])
    @IBOutlet weak var contentTableView: UITableView!

    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Configure TableView
        self.contentTableView.dataSource = self
        self.contentTableView.rowHeight = UITableViewAutomaticDimension
        self.contentTableView.estimatedRowHeight = 300
        
        // Fetch data
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
                self.contentTableView.reloadData()
            }
        }
    }
    
    //MARK:- TableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedContent.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lazyCell") as! ContentViewCell
        
        let imageElement = self.feedContent.images[indexPath.row]
        
        cell.contentImageView.image = imageElement.image
        cell.nameLabel.text = imageElement.name
        cell.descriptionLabel.text = imageElement.description
        
        return cell
    }

}

