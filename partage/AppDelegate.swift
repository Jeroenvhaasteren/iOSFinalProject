//
//  AppDelegate.swift
//  partage
//
//  Created by Jeroen van Haasteren on 25/05/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseMessaging
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var db: DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Override point for customization after application launch.
            FirebaseApp.configure()
            setupNotifications(application: application)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let isHandled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return isHandled
    }
    
    func setupNotifications(application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
            (isAuthorized, error) in
            print("isAutorized!")
        }
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        updateToken()
    }
    
    func connectToMessaging() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    func updateToken() {
        db = Database.database().reference()
        if let fcmToken = Messaging.messaging().fcmToken {
            if let currentUser = Auth.auth().currentUser {
                let installationInfo = ["token": fcmToken, "uid": currentUser.uid]
                self.db.child("installations").child(fcmToken).setValue(installationInfo)
            }
        }
    }
    
    //Start messaging Deligate func
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("token: " + fcmToken)
        connectToMessaging()
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Got a message!")
    }
    //End Messaging App Deligate

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
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
        updateToken()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

