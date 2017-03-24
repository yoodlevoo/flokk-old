//
//  FileUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

class FileUtils {
    //general load image
    //currently unused
    static func loadImage(fileName: String) -> UIImage {
        var image: UIImage!
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0]
            let readPath = NSURL(fileURLWithPath: dirPath as String).appendingPathComponent(fileName)
            
            do {
                image = try UIImage(data: Data(contentsOf: readPath!))!
            } catch let error as NSError {
                print("Error loading image: " + error.localizedDescription)
            } 
        }
        
        return image
    }
    
    //load an existing post's image form .../Documents/groupHandle/(post.uniqueName).png
    static func loadPostImage(group: Group, fileName: String) -> UIImage {
        var image: UIImage!
        
        let groupName = group.getFriendlyGroupName()
        
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupDirectory = documentsURL?.appendingPathComponent(groupName)
        let imageURL = groupDirectory?.appendingPathComponent(fileName + ".png")
        let absoluteImageURL = URL(fileURLWithPath: (imageURL?.absoluteString)!)
        
        do {
            //print(absoluteImageURL.absoluteString + " load post image")
            
            image = try UIImage(data: Data(contentsOf: absoluteImageURL))!
        } catch let error as NSError {
            print("Error loading image: " + error.localizedDescription)
        }
        
        return image
    }
    
    //load the groups "profile" icon from .../Documents/groupHandle/groupIcon.png
    static func loadGroupIcon(groupName: String) -> UIImage {
        var image: UIImage!
        
        //should this be just be inputted in the correct format(as in the groupName is already friendly)
        //or should i do this in this function like I am now
        let groupName = Group.createFriendlyGroupName(name: groupName)
        
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupDirectory = documentsURL?.appendingPathComponent(groupName)
        let imageURL = groupDirectory?.appendingPathComponent(groupName + "Icon.png")
        let absoluteImageURL = URL(fileURLWithPath: (imageURL?.absoluteString)!)
        
        do {
            image = try UIImage(data: Data(contentsOf: absoluteImageURL))!
        } catch let error as NSError {
            print("Error loading image: " + error.localizedDescription)
        }
        
        return image
    }
    
    //save a new post's image to .../Documents/groupHandle/(post.uniqueName).png
    @discardableResult static func savePostImage(post: Post) -> Bool {
        let groupName = post.postedGroup.getFriendlyGroupName()
        
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupDirectory = documentsURL?.appendingPathComponent(groupName)
        let imageURL = groupDirectory?.appendingPathComponent(post.getUniqueName() + ".png")
        let absoluteImageURL = URL(fileURLWithPath: (imageURL?.absoluteString)!)
        
        let image = post.image
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y:0, width:image.size.width, height:image.size.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(newImage!)
        let data = NSData(data: imageData!)
        
        do {
            // print(absoluteImageURL.absoluteString + " save post")
            //try imageData?.write(to: absoluteImageURL)
            return data.write(to: absoluteImageURL, atomically: true)
            
            //return true
        } catch let error as NSError {
            print("Error saving image" + error.localizedDescription)
            return false
        }
    }
    
    //save a groups main JSON file to .../Documents/groupHandle/groupHandle.json
    @discardableResult static func saveGroupJSON(json: JSON, group: Group) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupName = group.getFriendlyGroupName()
        
        let groupURL = documentsURL?.appendingPathComponent(groupName)
        let jsonURL = groupURL?.appendingPathComponent(groupName + ".json")
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            let dirExists = FileManager.default.fileExists(atPath: (groupURL?.absoluteString)!)
            if !dirExists {
                try FileManager.default.createDirectory(atPath: ((groupURL)?.absoluteString)!, withIntermediateDirectories: false, attributes: nil)
            }
            
            //print(jsonFile.absoluteString + " save group json")
            
            let data = try json.rawData()
            try data.write(to: jsonFile, options: .atomic)
            return true
        } catch let error as NSError {
            print("Error saving group json" + error.localizedDescription)
            return false
        }
    }
    
    //save the new created group's "profile" icon thats used when the group is being displayed
    //to .../Documents/groupHandle/groupHandleIcon.png
    @discardableResult static func saveGroupIcon(group: Group) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupName = group.getFriendlyGroupName()
        
        let groupURL = documentsURL?.appendingPathComponent(groupName)
        let picURL = groupURL?.appendingPathComponent(groupName + "Icon.png")
        let absolutePicURL = URL(fileURLWithPath: (picURL?.absoluteString)!)
        
        let image = group.groupIcon
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y:0, width:image.size.width, height:image.size.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(newImage!)
        let data = NSData(data: imageData!)
        
        return data.write(to: absolutePicURL, atomically: true)
    }
    
    //save the users's new json file
    //mainly used when creating a new group and adding it to the main user's
    //participating groups
    @discardableResult static func saveUserJSON(json: JSON, user: User) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let jsonURL = documentsURL?.appendingPathComponent(user.handle + ".json")
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            let data = try json.rawData()
            try data.write(to: jsonFile, options: .atomic)
            
            return true
        } catch let error as NSError {
            print("Error saving group json" + error.localizedDescription)
            return false
        }
    }
    
    //save the user's json file to the old filePath in /Flokk/JSON files/...
    //unused and not working
    static func saveUserJSONOld(json: JSON, user: User) {
        let path = Bundle.main.url(forResource: user.handle, withExtension: "json")
        
        do {
            let data = try json.rawData()
            try data.write(to: path!, options: .atomic)
        } catch let error as NSError {
            print("Error saving group json" + error.localizedDescription)
        }
    }
    
    //unused and unimplemented
    @discardableResult static func saveJSON(json: JSON, name: String) -> Bool {
        //let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        //let groupURL = documentsURL?.appendingPathComponent(APP_DISTINGUISHED_NAME)
        
        return false
    }
    
    //delete a specific group's json file
    //mainly used currently for testing purposes
    @discardableResult static func deleteGroupJSON(groupName: String) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let groupURL = documentsURL?.appendingPathComponent(groupName) //directory for file storage for this specific group
        let jsonURL = groupURL?.appendingPathComponent(groupName + ".json") //json file for this group stored in the relative directory
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            var success = try FileManager.default.removeItem(at: jsonFile)
            
            return true
        } catch let error as NSError {
            print(error.localizedDescription)
            
            return false
        }
    }
    
    //delete the mainUser's json file
    //mainly used currently for testing purposes
    @discardableResult static func deleteUserJSON(user: User) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let jsonURL = documentsURL?.appendingPathComponent(user.handle + ".json") //json file for this group stored in the relative directory
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            var success = try FileManager.default.removeItem(at: jsonFile)
            return true
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
        
        return false
    }
    
    static func deleteAllFiles() {
        
    }
    
    static func findAllFilesInDocuments() {
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
            //print("mp3 urls:",mp3Files)
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            //print("mp3 list:", mp3FileNames)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

extension JSON {
    mutating func appendIfArray(json:JSON){
        if var arr = self.array{
            arr.append(json)
            self = JSON(arr);
        }
    }
    
    mutating func appendIfDictionary(key:String,json:JSON){
        if var dict = self.dictionary{
            dict[key] = json;
            self = JSON(dict);
        }
    }
}
