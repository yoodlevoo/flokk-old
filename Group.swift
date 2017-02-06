//
//  File.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 1/27/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

class Group {
    var groupName: String
    var groupIcon: UIImage
    
    var participants = [User]() //the users that are in this group
    
    init() {
        self.groupName = "filler"
        self.groupIcon = UIImage(named: "HOME ICON")! //just some filler image
    }
    
    init(text: String, image: UIImage) {
        self.groupName = text
        self.groupIcon = image
    }
}
