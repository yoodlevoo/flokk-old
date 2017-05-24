//
//  Storage.swift
//  Flokk
//
//  Created by Jared Heyen on 5/12/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class Storage {
    var ref: FIRStorageReference!
    
    init() {
        ref = FIRStorage.storage().reference() // Create a reference from our storage service
    }
}
