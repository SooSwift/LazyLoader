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
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let downloadManager = OperationManager()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var contentTableView: UITableView!

    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Configure Refresh Control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        
        // Configure TableView
        self.contentTableView.dataSource = self
        self.contentTableView.rowHeight = UITableViewAutomaticDimension
        self.contentTableView.estimatedRowHeight = 100
        self.contentTableView.addSubview(self.refreshControl)
        self.contentTableView.tableFooterView = UIView()
        
        // Fetch data
        self.fetchDataFromJSONFeed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK:- Helper Methods
    private func fetchDataFromJSONFeed() {
        self.showProgressIndicator()
        
        ContentManager.getContentfromJSONFeed(urlString: Config.feedURL) { (success, content) in
        
            // Show alert to user on failure
            if(!success || content == nil) {
                DispatchQueue.main.async {
                    self.hideProgressIndicator()
                    
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
                self.hideProgressIndicator()
                
                self.title = content.title
                self.contentTableView.reloadData()
            }
        }
    }
    
    private func loadLazily(image:ImageElement, atIndexPath indexPath:IndexPath) {
    
        // Leave images in other states
        if image.status != .Default {
            return
        }
        
        // Check if image downloading already in progress
        if let _ = self.downloadManager.ongoingOperations[indexPath] {
            return
        }
        
        //Download images lazily
        let lazyDownloader = LazyDownloader(withImageElement: image)
        lazyDownloader.completionBlock = {
            if(lazyDownloader.isCancelled) {
                return
            }
            
            self.downloadManager.ongoingOperations.removeValue(forKey: indexPath)
            DispatchQueue.main.async {
                self.contentTableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        self.downloadManager.ongoingOperations[indexPath] = lazyDownloader
        self.downloadManager.operationQueue.addOperation(lazyDownloader)
    }
    
    private func createActivityIndicatorForCell(cell:ContentViewCell )->UIActivityIndicatorView {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.isHidden = false
        cell.contentImageView.addSubview(activityView)
        activityView.center = cell.contentImageView.center
        activityView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        return activityView
    }
    
    func onPullToRefresh() {
        self.refreshContent()
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
        
        let activityView = self.createActivityIndicatorForCell(cell: cell)
        switch imageElement.status {
        case .Default:
            activityView.startAnimating()
            self.loadLazily(image: imageElement, atIndexPath: indexPath)
        case .DownloadComplete:
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            break
        case .DownloadFailed:
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            cell.contentImageView.image = #imageLiteral(resourceName: "imagenotfound")
        }
        return cell
    }
    
    
    //MARK:- Activity Indicator methods
    func showProgressIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    func hideProgressIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }

    //MARK:- Refresh Handling
    func refreshContent() {
        self.refreshControl.endRefreshing()
        self.feedContent = Content(title: "", images: [])
        self.title = ""
        self.downloadManager.reset()
        self.contentTableView.reloadData()
        self.fetchDataFromJSONFeed()
    }
    
}

