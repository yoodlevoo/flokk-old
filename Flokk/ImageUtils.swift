//
//  ImageUtils.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/23/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func generateProfilePhotoWithText(text: String) -> UIImage {
        let image = UIImage(named: "Empty Profile Picture")!
        
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor.clear
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.text = text
        label.font = UIFont(name: "Josefin Sans", size: 55)
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0);
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return imageWithText!
    }
}

