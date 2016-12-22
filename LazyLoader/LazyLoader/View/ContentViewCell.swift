//
//  ContentViewCell.swift
//  LazyLoader
//
//  Created by Sachin Sawant on 22/12/16.
//  Copyright © 2016 Sachin Sawant. All rights reserved.
//

import UIKit

class ContentViewCell: UITableViewCell {

    //MARK:- Properties
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK:- View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
