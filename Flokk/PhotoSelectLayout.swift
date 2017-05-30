//
//  PhotoSelectLayoutAttributes.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/5/17.
//  Copyright © 2017 Flokk. All rights reserved.
//
//  From Ray Wenderlich's Pintrest Layout tutorial

import Foundation
import UIKit

protocol PhotoSelectLayoutDelegate {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath, withWidth:CGFloat) -> CGFloat
}

class PhotoSelectLayoutAttributes : UICollectionViewLayoutAttributes {
    // Custom attribute the cell will use to resize the image
    var photoHeight: CGFloat = 0.0
    
    // I override this function to guarantee the photoHeight property will be set when the object is copied
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PhotoSelectLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PhotoSelectLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        
        return false
    }
}

class PhotoSelectLayout: UICollectionViewLayout {
    var delegate: PhotoSelectLayoutDelegate!
    
    var numberOfColumns = 3
    var cellPadding: CGFloat = 6.0
    
    /*private*/ var cache = [PhotoSelectLayoutAttributes]() // Can't be private cause we clear it on every refresh
    
    private var contentHeight: CGFloat = 0.0 // Incremented as more photos are added
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    override class var layoutAttributesClass : AnyClass {
        return PhotoSelectLayoutAttributes.self
    }
    
    override func prepare() {
        // So cache only loads once
        // Work out a different way so we only have to load a certain part of the cache
        // like 'if cache.count < collectionView!.numberOfItems(inSection: 0) {...}'
        if cache.isEmpty {
            // Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns { //..< is half closed operator?
                xOffset.append(CGFloat(column) * columnWidth)
            }
            
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            // Iterate throught the list of items in the first collection
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                
                // Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
                let width = columnWidth - cellPadding * 2
                let photoHeight = delegate.collectionView(self.collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding + photoHeight + cellPadding // padding above and below the photo
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = PhotoSelectLayoutAttributes(forCellWith: indexPath as IndexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame

                cache.append(attributes)
                
                // Updates the collection view content height
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                if column >= (numberOfColumns - 1) {
                    column = 0
                } else {
                    column += 1
                }
            }
        }
    }
    
    // returns the size of the collection view's contents
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth - 20, height: contentHeight)
    }
    
    // Returns the layout attributes for all of the cells and views in the specified rectangle
    // - when would this be used?
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // go throught the attributes in cache
        for attributes in cache {
            // check if any of the attributes in cache intersect the rect
            if attributes.frame.intersects(rect) {
                // if they do, return them
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
}
