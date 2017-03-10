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
    
    static let numPhotosToLoad = 200
    
    var images = [UIImage]() //should i have this?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        if let layout = collectionView?.collectionViewLayout as? PhotoSelectLayout {
            layout.delegate = self
        }
        
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotoOptions)
        
        thumbnailSize = CGSize(width: 335, height: 667)
    }
    
    override func viewDidLayoutSubviews() {
        //self.collectionView.collectionViewLayout.invalidateLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoSelectViewController.numPhotosToLoad
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! PhotoSelectCell
        
        //cell.repres
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { image, _ in
            cell.imageView.image = image
        })
        
        //let screenWidth = UIScreen.main.bounds.width
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.tag = indexPath.item
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        var height: CGFloat = 5.0
        
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { image, _ in
            
            let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
            //calculate a height that retains the photo's aspect ratio
            let rect = AVMakeRect(aspectRatio: (image?.size)!, insideRect: boundingRect)
            
            height = rect.size.height
        })
        
        print("heightForPhotoAtIndexPath: \(height) at index \(indexPath.item)")
        return height
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
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    
                    let asset = fetchResult.object(at: tag)
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: screenWidth * 2, height: screenHeight * 2), contentMode: .default, options: nil, resultHandler: { image, _ in
                        
                        if confirmUploadNav.imageToPass != nil {
                            if let confirmUpload = confirmUploadNav.viewControllers[0] as? ConfirmUploadViewController {
                                //if confirmUpload.imageView != nil {
                                    //confirmUpload.imageView.image = image
                                //}
                                
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
    
    //@IBOutlet weak var imageViewHeightLayoutConsraint: NSLayoutConstraint!
}
