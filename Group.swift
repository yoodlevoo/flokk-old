//
//  File.swift
//  Flokk
//
//  Created by Taylor High School on 1/27/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

class Group {
    var groupName: String
    var groupIcon: UIImage
    
    init() {
        self.groupName = "filler"
        self.groupIcon = UIImage(named: "HOME ICON")! //just some filler image
    }
    
    init(text: String, image: UIImage) {
        self.groupName = text
        self.groupIcon = image
    }
    
    
}
