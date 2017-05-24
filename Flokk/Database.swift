//
//  Database.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 2/17/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

// A class that the framework of flokk can use to load data from Firebase.
// Most of the functions in this class will be static???, so a Database object doesn't need to be passed around.
// Basically all of these functions are write-only / no getter functions, as loading from the database is asynchronous
class Database {
    var ref: FIRDatabaseReference!
    
    init() {
        FIRApp.configure() // Initialize Firebase
        
        ref = FIRDatabase.database().reference() // Create a reference from our database service
    }
    
    func loadMainUserGroups() -> [Group] {
        return [Group]()
    }
    
    func createGroup(groupHandle: String, profileIcon: UIImage) {
        let groupData = ref.child("groups").child(groupHandle)
        
        groupData.child("creator").setValue(mainUser.handle) // the creator will always be the main user
        
        
    }
}

// User functions
extension Database {
    // Authenticate the user and add them to the database
    func createNewUser(email: String, password: String, handle: String, fullName: String, profilePhoto: UIImage) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user { // Make sure we got this user OK - might be redundant
                    self.ref.child("uids").child(user.uid).setValue(handle) // Connect this user's UID with their handle, for logging in
                    
                    // While this(below) doesnt need to be synchronous necessarily, if there is an error in the creation,
                    // I dont want the rest of the user to be added to the database
                    
                    // Write this new user's data to the database
                    let userDataRef = self.ref.child("users").child(handle)
                    
                    userDataRef.child("fullName").setValue(fullName)
                    userDataRef.child("email").setValue(email)
                    
                    //let groupHandles: [String: Bool] = ["basketball": true]
                    
                    //userDataRef.child("groups").setValue(groupHandles)
                    
                    //userDataRef.child("profilePhoto").setValue("\(handle)ProfilePhoto.jpg") // How should this be handled
                }
            } else {
                print(error!)
            }
        })
    }

    
    func uploadUserProfilePhoto(user: User, profilePhoto: UIImage) {
        
    }
}

// Group functions
extension Database {
    func inviteUsersToGroup(group: Group) {
        
    }
    
    func addPostToGroup(_ group: Group, image: UIImage) {
        
    }
}
