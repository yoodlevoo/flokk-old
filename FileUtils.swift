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
    
    static func saveImage(image: UIImage, name: String) -> Bool {
        let imageData = NSData(data: UIImagePNGRepresentation(image)!)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docs: NSString = paths[0] as NSString
        let fullPath = NSURL(fileURLWithPath: docs as String).appendingPathComponent(name)
        let result = imageData.write(to: fullPath!, atomically: true)
        
        return result
    }
    
    static func saveGroupJSON(json: JSON, groupName: String) -> Bool {
        let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let groupURL = documentsURL?.appendingPathComponent(groupName)
        let jsonURL = groupURL?.appendingPathComponent(groupName + ".json")
        let jsonFile = URL(fileURLWithPath: (jsonURL?.absoluteString)!)
        
        do {
            let dirExists = FileManager.default.fileExists(atPath: (groupURL?.absoluteString)!)
            if !dirExists {
                try FileManager.default.createDirectory(atPath: ((groupURL)?.absoluteString)!, withIntermediateDirectories: false, attributes: nil)
            }
            
            let data = try json.rawData()
            try data.write(to: jsonFile, options: .atomic)
            return true
        } catch let error as NSError {
            print("Error " + error.localizedDescription)
            return false
        }
    }
    
    static func saveJSON(json: JSON, name: String) -> Bool {
        //let documentsURL = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        //let groupURL = documentsURL?.appendingPathComponent(APP_DISTINGUISHED_NAME)
        
        return false
    }
    
    static func deleteGroupJSON(json: JSON, groupName: String) -> Bool {
        return false
    }
}
