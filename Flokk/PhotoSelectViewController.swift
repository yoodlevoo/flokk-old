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
    
    var forGroup: Group! // Just passing this around so we can return it to the feed
    
    static let initialNumPosts = 5 // Load more when scrolling down
    static let morePostsToLoad = 8 // Amount of posts to load each time when we need to on scrolling down
    var loadedPostsCount = initialNumPosts // The total amount of posts loaded
    
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
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotoOptions)
        
        thumbnailSize = CGSize(width: 335, height: 667) //default size of the iPhone screen - this should probably be dynamic
    }
    
    override func viewDidLayoutSubviews() {
        //self.collectionView.collectionViewLayout.invalidateLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("collectionview numberOfItemsInSection \(self.loadedPostsCount)")
        return self.loadedPostsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("collectionview cellForItemAt \(indexPath.item)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! PhotoSelectCell
        
        cell.imageView.image = images[indexPath.item] as? UIImage
        
        //Attempt to change this imageView's bounds so the cell shows the full image
        cell.imageView.contentMode = .scaleAspectFit
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        
        //set the cells tag so prepare(for: segue) knows which celll was selected
        cell.tag = indexPath.item
        
        return cell
    }
    
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        var height: CGFloat = 5.0
        
        if images.count - 1 < indexPath.item || images[indexPath.item] == nil {
            self.setImageInArray(index: indexPath.item)
        }
        
        let image = images[indexPath.item] as! UIImage
        
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        
        // Calculate a height that retains the photo's aspect ratio
        let rect = AVMakeRect(aspectRatio: (image.size), insideRect: boundingRect)
        
        height = rect.size.height
        
        return height
    }
    
    //check for if we need to have more cells
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //check if we're close to the bottom of the page and need to load more posts
        if indexPath.item == loadedPostsCount - 4 {
            //increase the amount of posts loaded
            loadedPostsCount += PhotoSelectViewController.morePostsToLoad
            
            //attempt to reload the data
            //self.collectionView.reloadData()
            
            //print("reloading data")
        }
    }
    
    private func setImageInArray(index: Int) {
        //at this point, the array should already be of sufficient size
        //so we don't have to check if the index is out of bounds
        let asset = fetchResult.object(at: index)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { image, _ in
            
            if image != nil {
                self.images[index] = image!
            } else {
                print("image at index \(index) is nil")
            }
        })
    }
    
    private func getSelectedImage(index: Int) -> UIImage {
        var selected: UIImage!
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let asset = fetchResult.object(at: index)
        imageManager.requestImage(for: asset, targetSize: CGSize(width: screenWidth * 2, height: screenHeight * 2), contentMode: .default, options: nil, resultHandler: { image, _ in
            
            if selected != nil {
                //ret = image
            }
            
            selected = image
        })
        
        return selected
    }
    
    @IBAction func unwindFromConfirmImageToPhotoSelect(segue: UIStoryboardSegue) {
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromPhotoSelectToConfirmImage" {
            if let confirmUploadView = segue.destination as? ConfirmUploadViewController {
                if let tag = (sender as? PhotoSelectCell)?.tag {
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    
                    confirmUploadView.forGroup = self.forGroup
                    
                    let asset = fetchResult.object(at: tag)
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: screenWidth * 2, height: screenHeight * 2), contentMode: .default, options: nil, resultHandler: { image, _ in
                        
                        if confirmUploadView.imageView != nil {
                            confirmUploadView.imageView.image = image
                        }
                        
                        confirmUploadView.image = image
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
