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
    
    func getCGImageWithCorrectOrientation(_ image : UIImage) -> CGImage {
        if (image.imageOrientation == UIImageOrientation.up) {
            return image.cgImage!;
        }
        
        var transform : CGAffineTransform = CGAffineTransform.identity;
        
        switch (image.imageOrientation) {
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height);
            transform = transform.rotated(by: CGFloat(-1.0 * M_PI_2));
            break;
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(M_PI_2));
            break;
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height);
            transform = transform.rotated(by: CGFloat(M_PI));
            break;
        default:
            break;
        }
        
        switch (image.imageOrientation) {
        case UIImageOrientation.rightMirrored, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        case UIImageOrientation.downMirrored, UIImageOrientation.upMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        default:
            break;
        }
        
        let contextWidth : Int;
        let contextHeight : Int;
        
        switch (image.imageOrientation) {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored,
             UIImageOrientation.right, UIImageOrientation.rightMirrored:
            contextWidth = (image.cgImage?.height)!;
            contextHeight = (image.cgImage?.width)!;
            break;
        default:
            contextWidth = (image.cgImage?.width)!;
            contextHeight = (image.cgImage?.height)!;
            break;
        }
        
        let context : CGContext = CGContext(data: nil, width: contextWidth, height: contextHeight,
                                            bitsPerComponent: image.cgImage!.bitsPerComponent,
                                            bytesPerRow: image.cgImage!.bytesPerRow,
                                            space: image.cgImage!.colorSpace!,
                                            bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!;
        
        context.concatenate(transform);
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(contextWidth), height: CGFloat(contextHeight)));
        
        let cgImage = context.makeImage();
        
        return cgImage!;
    }
    
    func getCroppedImage(image: UIImage) -> UIImage {
        let cgImage = getCGImageWithCorrectOrientation(image)
        let zoom = scrollView.zoomScale
        let offset = scrollView.contentOffset
        let frame = scrollView.frame
        
        let croppedImageRect = CGRect(x: offset.x / zoom, y: offset.y / zoom, width: frame.width, height: frame.height)
        let imageRef = cgImage.cropping(to: croppedImageRect)
        
        print("scrollview crop rect \(croppedImageRect)")
        
        let retImage = UIImage(cgImage: imageRef!)
        
        return retImage
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCancelCrop" {
            if let createGroupView = segue.destination as? CreateGroupViewController {
                
            }
        } else if segue.identifier == "segueChoseCropToCreateGroup" {
            if let createGroupView = segue.destination as? CreateGroupViewController {
                createGroupView.profilePicFromCrop = getCroppedImage(image: (imageView?.image)!)
                
                //testing
                /*
                var offset = scrollView.contentOffset
                var zoom = scrollView.zoomScale
                
                var rect = CGRect(x: offset.x / zoom, y: offset.y / zoom, width: scrollView.frame.width / zoom, height: scrollView.frame.height / zoom)
                print("scrollview crop rect \(rect)")
                print("scrollview bounds \(scrollView.bounds)")
                print("scrollview offset \(scrollView.contentOffset)") */
            }
        } else {
            
        }
    }
}
