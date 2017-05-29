//
//  UserTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 5/24/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit

// Connect all of the various user table view cells to this one
class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
