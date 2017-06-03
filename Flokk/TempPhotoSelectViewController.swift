//
//  TempPhotoSelectViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 6/2/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Toucan

class TempPhotoSelectViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var forGroup: Group! // Just passing this around so we can return it to the feed
    var groupIndex: Int! // The index of this group in the global groups array
    
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult<PHAsset>!
    var thumbnailSize: CGSize!
    
    let initialImageMax = 500 // Only load 300 at first
    var imageCount = 0 // The amount of images that are going to be loaded
    var totalImageCount: Int!
    
    let cellSize = CGSize(width: 115, height: 115)
    
    //var imageHeights = [IndexPath : CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
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
        
        // Get size of the collectionView cell for thumbnail image
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            //let cellSize = layout.itemSize
            //self.thumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
            self.thumbnailSize = self.cellSize
            //print(self.thumbnailSize)
        }
        
        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        
        if let photoCnt = self.photosAsset?.count{
            if(photoCnt == 0){
                //self.noPhotosLabel.isHidden = false
            } else {
                //self.noPhotosLabel.isHidden = true
            }
        }
        
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

extension TempPhotoSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! TempPhotoSelectCell
        
        let asset: PHAsset = self.photosAsset[indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 335 * 2, height: 667 * 2), contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if let image = result {
                cell.imageView.image = image
            }
        })
        
        // Resize and set the image
        //let resizedImage = Toucan(image: cell.imageView.image!).resize(self.cellSize, fitMode: Toucan.Resize.FitMode.crop).image
        //cell.imageView.image = resizedImage
        
        // Attempt to change this imageView's bounds so the cell shows the full image
        cell.imageView.contentMode = .scaleAspectFill
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        
        // Set the cells tag so prepare(for: segue) knows which celll was selected
        cell.tag = indexPath.item
        
        return cell
    }
}

extension TempPhotoSelectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
}

class TempPhotoSelectCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
}
