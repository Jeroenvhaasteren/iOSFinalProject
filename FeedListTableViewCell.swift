//
//  FeedListTableViewCell.swift
//  partage
//
//  Created by Jeroen van Haasteren on 08/06/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

class FeedListTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
