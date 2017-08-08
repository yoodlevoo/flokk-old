//
//  TextUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 4/19/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func getFormattedDate() -> String {
        return ""
    }
    
    
}

// Added two functions
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, _ size: Float) -> NSMutableAttributedString {
        let familyNames = UIFont.familyNames
        //print(familyNames)
        
        var fontnames = UIFont.fontNames(forFamilyName: "Georgia")
        //print(fontnames)
        
        fontnames = UIFont.fontNames(forFamilyName: "Josefin Sans")
        //print(fontnames)
        
        let josefinSans = UIFont(name: "Josefin Sans", size: CGFloat(size))
        
        let attributes:[String:AnyObject] = [NSFontAttributeName : josefinSans!]
        let boldString = NSMutableAttributedString(string: "\(text)", attributes: attributes)
        self.append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        self.append(normal)
        
        return self
    }
}
