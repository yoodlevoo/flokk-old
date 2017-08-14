//
//  Alert.swift
//  Flokk
//
//  Created by Gannon Prudomme on 8/12/17.
//  Copyright © 2017 Flokk. All rights reserved.
//

import Foundation
import UIKit

// A custom view that shows an alert over the super view
class Alert {
    // Activity alert variables
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    // Show an alert with an activity indicator
    func showActivityIndicator(_ view: UIView, _ title: String) {
        self.strLabel.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
        self.effectView.removeFromSuperview()
        self.effectView.alpha = 1 // Just in case it was transparent
        
        // Create the text label
        self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        self.strLabel.text = title
        self.strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        self.strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        // Make the text label only as long as the text
        self.strLabel.frame.size.width = (self.strLabel.attributedText?.width(withConstrainedHeight: 46))!
        
        // Create the effect view
        self.effectView.frame = CGRect(x: view.frame.midX - self.strLabel.frame.width/2 - 23, y: view.frame.height / 3, width: 30 + 46 + self.strLabel.frame.size.width, height: 46)
        self.effectView.layer.cornerRadius = 15
        self.effectView.layer.masksToBounds = true
        
        self.effectView.center = view.center
        
        // Create the activity indicator
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        self.activityIndicator.startAnimating()
        
        // Add all the views
        self.effectView.addSubview(activityIndicator)
        self.effectView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    // Show an alert without an activity indicator
    func showAlert(_ view: UIView, _ title: String) {
        // Basically the same function as above, without the activity indicator portion
        self.strLabel.removeFromSuperview()
        self.effectView.removeFromSuperview()
        self.effectView.alpha = 1
        
        // Create the text label
        self.strLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 160, height: 46))
        self.strLabel.text = title
        self.strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        self.strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        // Make the text label only as long as the text
        self.strLabel.frame.size.width = (self.strLabel.attributedText?.width(withConstrainedHeight: 46))!
        
        // Create the effect viewa
        self.effectView.frame = CGRect(x: view.frame.midX, y: view.frame.height / 3, width: 20 + self.strLabel.frame.size.width, height: 46)
        self.effectView.layer.cornerRadius = 15
        self.effectView.layer.masksToBounds = true
        
        // Center the view
        self.effectView.center = view.center
        
        // Add all the views
        self.effectView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    // Remove either type of alert
    func removeActivityIndicator() {
        self.strLabel.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
        self.effectView.removeFromSuperview()
    }
    
    // Show an alert that disappears after a duration
    func showDisappearingAlert(_ view: UIView, _ title: String, duration: TimeInterval = 2.0) {
        self.showAlert(view, title)
        
        // Wait for "ALERT_DISAPPEAR_DELAY" amount of seconds, then make the alert disappear
        UIView.animate(withDuration: ALERT_DISAPPEAR_DELAY, animations: {
        }, completion: { (completed) in
            UIView.animate(withDuration: duration, animations: {
                self.effectView.alpha = 0
            }, completion: { (completed) in
                self.removeActivityIndicator()
            })
        })
    }
}
