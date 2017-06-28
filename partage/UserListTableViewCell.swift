//
//  UserListTableViewCell.swift
//  partage
//
//  Created by Jeroen van Haasteren on 01/06/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

protocol UserListTableViewCellDelegate: class {
    func userCellFollowButtonPressed(sender: UserListTableViewCell)
}


class UserListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: UserListTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func followButtonPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.userCellFollowButtonPressed(sender: self)
        }
    }
}
