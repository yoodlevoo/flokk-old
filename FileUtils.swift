//
//  FileUtils.swift
//  Flokk
//
//  Created by Jared Heyen on 3/1/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import Foundation
import UIKit

class FileUtils {
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
    
    static func loadPostImage(group: Group, fileName: String) -> UIImage {
        var image: UIImage!
        
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupDirectory = documentsURL?.appendingPathComponent(group.createFriendlyGroupName(name: group.groupName))
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
    
    static func savePostImage(post: Post) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupDirectory = documentsURL?.appendingPathComponent(post.postedGroup.createFriendlyGroupName(name: post.postedGroup.groupName))
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
            //print(absoluteImageURL.absoluteString + " save post")
            try imageData?.write(to: absoluteImageURL)
            return data.write(to: absoluteImageURL, atomically: true)
            
            //return true
        } catch let error as NSError {
            print("Error saving image" + error.localizedDescription)
            return false
        }
    }
    
    static func saveGroupJSON(json: JSON, group: Group) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupName = group.createFriendlyGroupName(name: group.groupName)
        
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
    
    static func saveJSON(json: JSON, name: String) -> Bool {
        //let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        //let groupURL = documentsURL?.appendingPathComponent(APP_DISTINGUISHED_NAME)
        
        return false
    }
    
    static func deleteGroupJSON(groupName: String) -> Bool {
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
    
    static func deleteAllFiles() {
        
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
