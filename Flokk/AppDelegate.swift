//
//  AppDelegate.swift
//  Tutorial
//
//  Created by Jared Heyen on 10/7/16.
//  Copyright © 2016 Flokk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications

var mainUser: User!
var database: Database!
var storage: Storage!
var groups = [Group]() // Should i do groups like this so they only need to be loaded once?
var storedUsers = [String : User]() // Dict of all of the loaded users, should probably clean up from time to time, has to have profile photo & handle at the least

// Color constants
let TEAL_COLOR = UIColor(colorLiteralRed: 56.0/255.0, green: 161.0/255.0, blue: 159.0/255.0, alpha: 1.0)
let NAVY_COLOR = UIColor(colorLiteralRed: 21.0/255.0, green: 22.0/255.0, blue: 43.0/255.0, alpha: 1.0)

let MIN_PASSWORD_LENGTH = 6
let MAX_PROFILE_PHOTO_SIZE: Int64 = 1 * 4096 * 4096
let MAX_POST_SIZE: Int64 = 1 * 4096 * 4096

let BANNER_DURATION: TimeInterval = 3.0

let RESIZED_ICON_WIDTH = CGFloat(337)
let MAX_POST_WIDTH = CGFloat(337 * 2)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Use Firebase library to configure APIs
        database = Database()
        storage = Storage()
        
        let token = FIRInstanceID.instanceID().token()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            FIRMessaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
//         Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    //remove all the stored files
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    /// The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}
