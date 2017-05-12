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

// A class that the framework of flokk can use to load data from the database.
// Most of the functions in this class will be static, so a Database object doesn't need to be passed around.
class Database {
    private var databaseRef: FIRDatabaseReference!
    private var storageRef: FIRStorageReference!
    
    init() {
        FIRApp.configure()
        
        databaseRef = FIRDatabase.database().reference() // Create a reference from our database service
        storageRef = FIRStorage.storage().reference() // Create a reference from our storage service
    }
    
    func loadMainUserGroups() -> [Group] {
        return [Group]()
    }
    
    func createGroup(groupHandle: String, creator: User, profileIcon: UIImage) {
        let groupData = databaseRef.child(groupHandle)
        
        groupData.child("creator").setValue(creator.handle)
        groupData.child("members").set
    }
}

// User functions
extension Database {
    // Authenticate the user and add them to the database
    func createNewUser(email: String, password: String, handle: String, fullName: String, profilePhoto: UIImage) {
        let userData = databaseRef.child(handle)
        
        userData.child("fullName").setValue(fullName)
        userData.child("email").setValue(email)
        userData.child("profilePhoto").setValue("\(handle)ProfilePhoto.jpg") // How should this be handled
    }
    
    // Load in data about this user
    func getUserWithHandle(_ handle: String) -> User {
        var userData = databaseRef.child(handle)
        
        var fullName = userData.child("fullName")
        var profilePhoto = UIImage()
        
        return User(handle: handle, fullName: fullName)
    }
    
    // Get the groups this user is participating in (and all of the basic data)
    func getUserGroups(user: User) -> [Group] {
        var groups = [Group]() // The groups to return
        
        
        return groups
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
