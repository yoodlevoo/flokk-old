//
//  User.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/3/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

//A class that represents all user in Flokk.
//There will be a user clas created for the main user(the one that is logged in and using the local app),
//as well as each user the main user interacts with.
class User {
    var usernameHandle: String!
    var fullName: String!
    var groups = [Group]() //the groups this user is in
    
    var mainUser: Bool! //is it the main/local user
    
    init(usernameHandle: String, fullName: String) {
        self.usernameHandle = usernameHandle
        self.fullName = fullName
        
        //load in this user's group from the database
        //self.groups = ??
    }
}
