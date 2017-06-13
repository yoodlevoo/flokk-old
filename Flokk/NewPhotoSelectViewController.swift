//
//  PhotoSelectViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class NewPhotoSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PhotoSelectLayoutDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var forGroup: Group! // Just passing this around so we can return it to the feed
    var groupIndex: Int! // The index of this group in the global groups array
    
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult<PHAsset>!
    var thumbnailSize: CGSize!
    
    let initialImageMax = 500 // Only load 300 at first
    var imageCount = 0 // The amount of images that are going to be loaded
    var totalImageCount: Int!
    
    //var imageHeights = [IndexPath : CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        
        if let layout = collectionView?.collectionViewLayout as? PhotoSelectLayout {
            layout.delegate = self
            
            let cellSize = layout.collectionViewContentSize
            self.thumbnailSize = CGSize(width: 335, height: 667)
            //self.thumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        let fetchOptions = PHFetchOptions()
        //fetchOptions.predicate = NSPredicate(format: "title = %@", "Flokk") // Fetch all options
        //fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // Sort by the most recent photos
        let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOptions)
        
        if let firstObj: AnyObject = collection.firstObject {
            self.assetCollection = firstObj as! PHAssetCollection
            print(firstObj)
        } else {
            print("Couldnt find the folder or something")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int = 0
        
        if self.photosAsset != nil {
            count = self.photosAsset.count
            self.totalImageCount = count
        }
        
        if self.imageCount == 0 { // Only on launch
            if count > self.initialImageMax {
                //self.imageCount = self.initialImageMax
                self.imageCount = count
            } else {
                self.imageCount = count
            }
        }
        
        return self.imageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! PhotoSelectCell
        
        let asset: PHAsset = self.photosAsset[indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if let image = result {
                cell.imageView.image = image
            }
        })
        
        // Attempt to change this imageView's bounds so the cell shows the full image
        cell.imageView.contentMode = .scaleAspectFit
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
            
        // Set the cells tag so prepare(for: segue) knows which celll was selected
        cell.tag = indexPath.item
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        var height: CGFloat = 50.0
        var image: UIImage!
        
        /*
        //if !self.imageHeights.keys.contains(indexPath) { // If we haven't already loaded this height
            // Calculate the image's height
            // Try to find a way around loading the image twice, as it literally doubles the load time
            let asset: PHAsset = self.photosAsset[indexPath.item]
            PHImageManager.default().requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
                if let img = result {
                    image = img
                    let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
                    
                    // Calculate a height that retains the photo's aspect ratio
                    let rect = AVMakeRect(aspectRatio: (image.size), insideRect: boundingRect)
                    height = rect.size.height
                    
                    //self.imageHeights[indexPath] = height
                }
            })
        //} else { // If we have already loaded this height
         //   height = self.imageHeights[indexPath]! // Get it from the imageHeights dict
        //} */
        
        return height
    }
    
    @IBAction func unwindFromConfirmImageToPhotoSelect(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromPhotoSelectToConfirmImage" {
            if let confirmUploadView = segue.destination as? ConfirmUploadViewController {
                if let tag = (sender as? PhotoSelectCell)?.tag {
                    confirmUploadView.groupIndex = self.groupIndex
                    
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    
                    confirmUploadView.forGroup = self.forGroup
                    
                    let asset: PHAsset = self.photosAsset[tag]
                    PHImageManager.default().requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
                        if let image = result {
                            
                            DispatchQueue.main.async {
                                if confirmUploadView.imageView != nil {
                                    confirmUploadView.imageView.image = image
                                }
                                
                                confirmUploadView.image = image
                            }
                        }
                    })
                }
            }
        }
    }
}

/*
class PhotoSelectCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightLayoutConsraint: NSLayoutConstraint!
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PhotoSelectLayoutAttributes {
            imageViewHeightLayoutConsraint.constant = attributes.photoHeight
        }
    }
} */
