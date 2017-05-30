//
//  ProfileSettingsViewController.swift
//  Flokk
//
//  Created by Jared Heyen on 11/3/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    @IBOutlet weak var passwordField: UITextField!
    
    //var mainUser: User!
    
    private let imagePicker = UIImagePickerController()
    
    let transitionRight = SlideRightAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profilePicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageView.contentMode = .scaleAspectFit
            profilePictureButton.setImage(pickedImage, for: UIControlState.normal)
        } else {
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backPage(_ sender: AnyObject) {
        
    }
    
    @IBAction func saveBttn(_ sender: AnyObject) {
        
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToProfileSettings(segue: UIStoryboardSegue) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromSettingsToPushNotificationSettings" {
           segue.destination.transitioningDelegate = transitionRight
        }
    }
}
