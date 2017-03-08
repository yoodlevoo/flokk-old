//
//  CropGroupPhotoViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 3/6/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class CropGroupPhotoViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    var imageSize: CGSize = CGSize.zero
    
    var zoomHeight: CGFloat!
    var zoomWidth: CGFloat!
    
    var image: UIImage!
    
    var cropSize: CGSize = CGSize(width: 100, height: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        //var viewWidth = self.view.frame.width
        //var viewHeight = self.view.frame.height
        
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.maximumZoomScale = 7.5
        //scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //only called once when opened
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
        
        //print("minScale \(minScale)")
    }
    
    private func updateConstraintsForSize(size: CGSize) {
        //let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        //imageViewTopConstraint.constant = yOffset
        //imageViewBottomConstraint.constant = yOffset
        
        //let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        //imageViewLeadingConstraint.constant = xOffset
        //imageViewTrailingConstraint.constant = xOffset
        
        //print("sizes: x:\(size.width) y:\(size.height)")
        //print("offsets: x:\(xOffset) y:\(yOffset)")
        //print("imageView: x:\(imageView.frame.height) y:\(imageView.frame.height)")
        
        //print("\(scrollView.bounds)")
        //print("\(scrollView.zoomScale)")
        
        //let zoom = scrollView.zoomScale
        //let imageSize = imageView.image?.size
        
        //let croppedSize = CGSize(width: (imageSize?.width)! / zoom, height: (imageSize?.height)! / zoom)
        
        //print("\(croppedSize)")
        
        view.layoutIfNeeded()
    }
    
    //
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(size: self.view.bounds.size)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: view.bounds.size)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCancelCrop" {
            if let createGroupView = segue.destination as? CreateGroupViewController {
                
            }
        } else if segue.identifier == "segueChoseCropToCreateGroup" {
            if let createGroupView = segue.destination as? CreateGroupViewController {
                let bounds = scrollView.bounds
                let zoom = scrollView.zoomScale
                let imageSize = imageView.image?.size
                
                let croppedSize = CGSize(width: (imageSize?.width)! / zoom, height: (imageSize?.height)! / zoom)
                
                let cropRect = CGRect(x: bounds.minX - ((imageSize?.width)! / 2), y: bounds.minY - ((imageSize?.height)! / 2), width: croppedSize.width, height: croppedSize.height)
                if let imageRef = imageView.image?.cgImage?.cropping(to: cropRect) {
                    let retImage = UIImage(cgImage: imageRef, scale: zoom, orientation: .up)
                    
                    createGroupView.profilePicFromCrop = retImage
                } else {
                    
                    print("bounds: \(bounds) croppedSize: \(croppedSize)")
                }
                
                //createGroupView.addGroupPictureButton.imageView?.image = retImage
                
            }
        } else {
            
        }
    }
}
