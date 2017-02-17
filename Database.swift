//
//  Database.swift
//  Flokk
//
//  Created by Taylor High School on 2/17/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation

//A class that the framework of flokk can use to load data from the database.
//Most of the functions in this class will be static, so a Database object doesn't need to be passed around.
class Database {
    static func loadUserWith(handle: String) -> User {
        //implement later
        return User(usernameHandle: "filler", fullName: "Filler Name")
    }
}
