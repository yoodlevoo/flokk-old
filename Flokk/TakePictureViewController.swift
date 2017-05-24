//
//  TakePictureViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 2/27/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import UIKit
import AVFoundation

class TakePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imagePicked: UIImageView!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    //if we find a capture device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        
        let devices = AVCaptureDevice.devices()
        
        //loop through all the capture devices on tis phone
        for device in devices! {
            // Make sure this particular device supports video
            if (device as AnyObject).hasMediaType(AVMediaTypeVideo) {
                // Finally check the position and confirm we've got the back camera
                if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                    }
                }
            }
        }
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .locked
                device.unlockForConfiguration()
            } catch let error as NSError {
                print("Error \(error)")
            }
        }
    }
    
    func focusTo(value: Float) {
        if let device = captureDevice {
            //first we lock the camera device
            
            do {
                try device.lockForConfiguration()
                
                //then we call this method to tell the lens to focus to point 'value'
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { time -> Void in
                //
                })
            
                device.unlockForConfiguration()
            } catch let error as NSError {
                print("Error " + error.localizedDescription)
            }
        }
    }
    
    
    let screenWidth = UIScreen.main.bounds.size.width
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var anyTouch = touches.first! as UITouch
        var touchPercent = anyTouch.location(in: self.view).x / screenWidth
        focusTo(value: Float(touchPercent))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var anyTouch = touches.first! as UITouch
        var touchPercent = anyTouch.location(in: self.view).x / screenWidth
        focusTo(value: Float(touchPercent))
    }
 
    
    func beginSession() {
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(previewLayer!)
            previewLayer?.frame = self.view.layer.frame
            captureSession.startRunning()
        } catch let error as NSError {
            print("Error  \(error)")
        }
    }
    
    @IBAction func openCameraButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
