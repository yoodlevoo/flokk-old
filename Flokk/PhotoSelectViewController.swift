//
//  PhotoSelectViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/1/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
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
    
    var forGroup: Group! //just passing this around so we can return it to the feed
    
    static let initialNumPosts = 10 //load more when scrolling down
    static let morePostsToLoad = 8 //amount of posts to load each time when we need to on scrolling down
    var loadedPostsCount = initialNumPosts //the total amount of posts loaded
    
    var images = NSMutableArray(capacity: PhotoSelectViewController.initialNumPosts) //should i have this?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        
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
        
        cell.imageView.image = images[indexPath.item] as! UIImage
        
        //Attempt to change this imageView's bounds so the cell shows the full image
        cell.imageView.contentMode = .scaleAspectFit
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        
        //set the cells tag so prepare(for: segue) knows which celll was selected
        cell.tag = indexPath.item
        
        //print("at index \(indexPath.item) cell: \(cell.bounds) imageView: \(cell.imageView.bounds) imageSize: \(cell.imageView.image?.size)")
        
        return cell
    }
    
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        var height: CGFloat = 5.0
        
        if images.count - 1 < indexPath.item || images[indexPath.item] == nil {
            self.setImageInArray(index: indexPath.item)
        }
        
        let image = images[indexPath.item] as! UIImage
        
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        
        //calculate a height that retains the photo's aspect ratio
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
            
            //set the image in the array
            self.images[index] = image!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromPhotoSelectToConfirmImage" {
            if let confirmUploadNav = segue.destination as? ConfirmUploadNavigationViewController {
                if let tag = (sender as? PhotoSelectCell)?.tag {
                    print("selected photo at index \(tag)")
                    
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    
                    let asset = fetchResult.object(at: tag)
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: screenWidth * 2, height: screenHeight * 2), contentMode: .default, options: nil, resultHandler: { image, _ in
                        
                        if confirmUploadNav.imageToPass != nil {
                            if let confirmUpload = confirmUploadNav.viewControllers[0] as? ConfirmUploadViewController {
                                if confirmUpload.imageView != nil {
                                    confirmUpload.imageView.image = image
                                }
                                
                                confirmUpload.image = image
                            }
                            
                        }
                        
                        confirmUploadNav.imageToPass = image
                    })
                    
                    confirmUploadNav.groupToPass = forGroup
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
