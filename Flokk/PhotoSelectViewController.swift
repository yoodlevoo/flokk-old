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

class PhotoSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PhotoSelectLayoutDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
    let imageManager = PHCachingImageManager()
    var thumbnailSize: CGSize!
    
    var group: Group! // Just passing this around so we can return it to the feed
    var groupIndex: Int! // The index of this group in the global groups array
    
    static let initialNumPosts = 10 // Load more when scrolling down
    static let morePostsToLoad = 8 // Amount of posts to load each time when we need to on scrolling down
    var totalPhotos = 0 // Load this in from the photo library, not have it as a static amount
    var loadedPostsCount = 0 // The total amount of posts loaded
    
    var images = NSMutableArray(capacity: PhotoSelectViewController.initialNumPosts) //should i have this?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        
        if let layout = collectionView?.collectionViewLayout as? PhotoSelectLayout {
            layout.delegate = self
        }
        
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // Sort by the most recent photos
        fetchResult = PHAsset.fetchAssets(with: .image, options: allPhotoOptions) // Only get the images
        
        self.totalPhotos = fetchResult.count // The amount of photos
        
        thumbnailSize = CGSize(width: 335, height: 667) //default size of the iPhone screen - this should probably be dynamic
        
        self.loadImages(from: 0, to: PhotoSelectViewController.initialNumPosts - 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! PhotoSelectCell
        
        DispatchQueue.main.async {
            cell.imageView.image = self.images[indexPath.item] as? UIImage
            
            // Attempt to change this imageView's bounds so the cell shows the full image
            cell.imageView.contentMode = .scaleAspectFit
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
            
            // Set the cells tag so prepare(for: segue) knows which celll was selected
            cell.tag = indexPath.item
            
            if indexPath.item == self.loadedPostsCount - 1{ // If this is the last photo
                if self.totalPhotos > self.loadedPostsCount { // If there are still more photos to load
                    self.loadImages(from: self.loadedPostsCount, to: self.loadedPostsCount + PhotoSelectViewController.morePostsToLoad - 1) // Load more posts
                }
            }
        }
        
        return cell
    }

    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        var height: CGFloat = 5.0
        
        let image = images[indexPath.item] as! UIImage
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        
        // Calculate a height that retains the photo's aspect ratio
        let rect = AVMakeRect(aspectRatio: (image.size), insideRect: boundingRect)
        height = rect.size.height
        
        return height
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //print("Disappearing\(indexPath.item)")
        
        if self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
            //self.images.remove(indexPath.item)
        }
    }
    
    @IBAction func unwindFromConfirmImageToPhotoSelect(segue: UIStoryboardSegue) {
        
    }
    
    // Called every time we need to load more images
    func loadImages(from startIndex: Int, to endIndex: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Load the images [startIndex, endIndex]
        for i in startIndex...endIndex {
            self.loadedPostsCount += 1 // Increase the amounts of post each time one is being loaded
            
            // Fetch the image from the Photo Library
            let asset = fetchResult.object(at: i)
            imageManager.requestImage(for: asset, targetSize: CGSize(width: screenWidth * 2, height: screenHeight * 2), contentMode: .default, options: nil, resultHandler: { image, _ in
                
                // Refresh the the collection view on the main thread
                DispatchQueue.main.async {
                    self.images[i] = image! // Set the loaded image in the images array
                    
                    //(self.collectionView.collectionViewLayout as! PhotoSelectLayout).cache.removeAll() // Clear the cache so the new cells will pop up
                    self.collectionView.collectionViewLayout.invalidateLayout() // Trigger a layout update
                    self.collectionView.reloadData() // Try not to do this every time an image is loaded
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromPhotoSelectToConfirmImage" {
            if let confirmUploadView = segue.destination as? ConfirmUploadViewController {
                if let tag = (sender as? PhotoSelectCell)?.tag {
                    confirmUploadView.groupIndex = self.groupIndex
                    
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    
                    confirmUploadView.group = self.group
                    
                    let asset = fetchResult.object(at: tag)
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: screenWidth * 2, height: screenHeight * 2), contentMode: .default, options: nil, resultHandler: { image, _ in
                        
                        DispatchQueue.main.async {
                            if confirmUploadView.imageView != nil {
                                confirmUploadView.imageView.image = image
                            }
                            
                            confirmUploadView.image = image
                        }
                    })
                }
            }
        }
    }
}

class PhotoSelectCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightLayoutConsraint: NSLayoutConstraint!
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PhotoSelectLayoutAttributes {
            imageViewHeightLayoutConsraint.constant = attributes.photoHeight
        }
    }
}
