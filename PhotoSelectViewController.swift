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
    
    static let numPhotosToLoad = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotoOptions)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        if let layout = collectionView?.collectionViewLayout as? PhotoSelectLayout {
            layout.delegate = self
        }
        
        //let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //layout.minimumLineSpacing = 2
        //layout.minimumInteritemSpacing = 2
        //layout.itemSize.width = screenWidth / 3 - 4
        //layout.itemSize = CGSize(width: screenWidth / 3 - 4, height: screenHeight / 3 - 4)
        
        let scale = UIScreen.main.scale
        //let cellSize = (collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: screenWidth / 3 * scale, height: screenWidth / 3 * scale)
        
        //collectionView.collectionViewLayout = layout
        
        //collectionView.item
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
            //cell.setCustomImage(image: cell.imageView.image!)
            //cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 100, height: 100)
        })
        
        //let screenWidth = UIScreen.main.bounds.width
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.tag = indexPath.item
        
        //cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: (cell.imageView.image?.size.width)!, height: (cell.imageView.image?.size.height)!)
        //cell.frame.size.width = screenWidth / 3
        //cell.frame.size.height = screenWidth / 3
        
        /*
        if indexPath.item == PhotoSelectViewController.numPhotosToLoad - 1 {
            self.collectionView.collectionViewLayout.invalidateLayout() //triggers a layout update
        } */
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        var height: CGFloat = 50.0
        
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { image, _ in
            
            let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
            let rect = AVMakeRect(aspectRatio: (image?.size)!, insideRect: boundingRect)
            
            height = rect.size.height
        })
        
        return height
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoSelectCell {
            print("\(cell.imageView.bounds.width) \(cell.imageView.bounds.height)")
            return CGSize(width: UIScreen.main.bounds.width / 3, height: cell.imageView.bounds.height)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 3, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 2, 0, 0)
        //return UIEdgeInsetsMake(0, 14, 0, 14)
    }
    */
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
    
    @IBOutlet weak var imageViewHeightLayoutConsraint: NSLayoutConstraint!
    
    /*
    //internally calculate the constraint for this aspect fit
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                imageView.removeConstraint(oldValue!)
            }
            
            if aspectConstraint != nil {
                imageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setCustomImage(image: UIImage) {
        let aspect = (image.size.width / image.size.height)// / (UIScreen.main.bounds.width / 3)
        let constraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: aspect, constant: 0.0)
        
        constraint.priority = 999
        
        aspectConstraint = constraint
        //print(constraint.description)
        
        imageView.image = image
    } */
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if let attributes = layoutAttributes as? PhotoSelectLayoutAttributes {
            imageViewHeightLayoutConsraint.constant = attributes.photoHeight
        }
    }
}
