//
//  PhotoSelectViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 3/1/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
    let imageManager = PHCachingImageManager()
    var thumbnailSize: CGSize!
    
    var forGroup: Group! //just passing this around so we can return it to the feed
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotoOptions)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.itemSize = CGSize(width: screenWidth / 3 - 4, height: screenWidth / 3 - 4)
        
        let scale = UIScreen.main.scale
        //let cellSize = (collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: screenWidth / 3 * scale, height: screenWidth / 3 * scale)
        
        collectionView.collectionViewLayout = layout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
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
        //cell.frame.size.width = screenWidth / 3
        //cell.frame.size.height = screenWidth / 3
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selected: UIImage!
        
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .default, options: nil, resultHandler: { image, _ in
    
            selected = image
        })
    } */
    
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
                            let confirmUpload = confirmUploadNav.viewControllers[0] as! ConfirmUploadViewController
                            confirmUpload.imageView.image = image
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
    
}
