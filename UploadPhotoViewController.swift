//
//  UploadPhotoViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 2/28/17.
//  Copyright © 2017 Heyen Enterprises. All rights reserved.
//

import UIKit

class UploadPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .scaleAspectFit
        imagePicker.delegate = self
        getLastImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        } else {
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func uploadPhoto(_ sender: Any) {
        print("Upload Photo")
        
        let imageData = NSData(data: UIImagePNGRepresentation(imageView.image!)!)
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var docs: NSString = paths[0] as NSString
        let fullPath = NSURL(fileURLWithPath: docs as String).appendingPathComponent("cache.png")
        //print(fullPath?.absoluteString)
        let result = imageData.write(to: fullPath!, atomically: true)
        
        print(result)
    }
    
    func getLastImage() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0]
            let readPath = NSURL(fileURLWithPath: dirPath as String).appendingPathComponent("cache.png")
            //print(readPath?.absoluteString)
            do {
                let image = try UIImage(data: Data(contentsOf: readPath!))
                imageView.image = image
            } catch let error as NSError {
                print("Error " + error.localizedDescription)
            }
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
