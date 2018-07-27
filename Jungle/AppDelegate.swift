//
//  AppDelegate.swift
//  Jungle
//
//  Created by Robert Canton on 2018-02-16.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import AVFoundation
import UserNotifications

var firestore:Firestore {
    return Firestore.firestore()
}

var database:DatabaseReference {
    return Database.database().reference()
}

var storage:StorageReference {
    return Storage.storage().reference()
}

var functions = Functions.functions()

var gpsService = GPSService()

let API_ENDPOINT = "https://us-central1-jungle-anonymous.cloudfunctions.net/app"

let accentColor = hexColor(from: "#72E279")
let accentDarkColor = hexColor(from: "#81d891")
let tagColor = hexColor(from: "#1696e0")
let redColor = hexColor(from: "FF6B6B")
let grayColor = UIColor(white: 0.75, alpha: 1.0)
let tertiaryColor = hexColor(from: "BEBEBE")
let subtitleColor = hexColor(from: "708078")
let bgColor = hexColor(from: "#eff0e9")
let likeColor = UIColor(rgb: (255, 102, 102))

var listeningDict = [String:Bool]() {
    didSet {
        print("NEWFOUNDLAND: \(listeningDict)")
    }
}
var currentUser:User?
var safeAreaInsets:UIEdgeInsets = .zero

protocol AppProtocol {
    func listenToAuth()
}

var appProtocol:AppProtocol!
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, AppProtocol {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override  for customization after application launch.
        
        appProtocol = self
        Messaging.messaging().delegate = self
        
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        settings.areTimestampsInSnapshotsEnabled = true
        // Enable offline data persistence
        
        createDirectory("captured")
        createDirectory("user_content")
        createDirectory("anon_icons")
        
        let db = Firestore.firestore()
        db.settings = settings
        
        if let user = Auth.auth().currentUser {
            user.getIDTokenForcingRefresh(true, completion: { token, error in
                if token != nil, error == nil {
                    print("NEW TOKEN")
                } else {
                    print("SIGNOUT")
                    do {
                        try Auth.auth().signOut()
                    } catch {}
                }
                self.listenToAuth()
            })
        } else {
            self.listenToAuth()
        }
    
        
        GIFService.getTopTrendingGif { _gif in
            if let gif = _gif {
                let thumbnailDataTask = URLSession.shared.dataTask(with: gif.thumbnail_url) { data, _, _ in
                    DispatchQueue.main.async {
                        if let data = data {
                            GIFService.tendingGIFImage = UIImage.gif(data: data)

                        }
                    }
                }
                thumbnailDataTask.resume()
            }
        }
        
        do {
            //            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,with:
            //                [AVAudioSessionCategoryOptions.mixWithOthers,
            //                 AVAudioSessionCategoryOptions.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("error")
        }
        return true
    }
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously() { (user, error) in
            
        }
    }
    var authListener:AuthStateDidChangeListenerHandle?
    func listenToAuth() {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
        
        authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("AUTH STATE CHANGED!: \(auth)")
            if let user = user {
                
                print("WE ARE HERE DUDE")
                print("UID: \(user.uid)")
                
                functions.httpsCallable("userAccount").call { result, error in
                    if let data = result?.data as? [String:Any], error == nil,
                        let type = data["type"] as? String {
                        var locationServices = false
                        var pushNotifications = false
                        var safeContentMode = false
                        if let settings = data["settings"] as? [String:Any] {
                            if let _locationSerivces = settings["locationServices"] as? Bool {
                                locationServices = _locationSerivces
                            }
                            if let _pushNotifications = settings["pushNotifications"] as? Bool {
                                pushNotifications = _pushNotifications
                            }
                            if let _safeContentMode = settings["safeContentMode"] as? Bool {
                                safeContentMode = _safeContentMode
                            }
                        }
                        let settings = UserSettings(locationServices: locationServices,
                                                    pushNotifications: pushNotifications,
                                                    safeContentMode: safeContentMode)
                        UserService.currentUserSettings = settings
                        UserService.currentUser = User(uid: user.uid, authType: type, lastPostedAt: nil)
                        currentUser = User(uid: user.uid, authType: type, lastPostedAt: nil)
                        UserService.observeCurrentUserSettings()
                        self.openMainView()
                        
                    } else {
                        print("ERROR: \(error?.localizedDescription)")
                    }
                }
//                UserService.getUser(user.uid) { user in
//                    currentUser = user
//                    if currentUser != nil {
//                        self.openMainView()
//                    }
//                }
            } else {
                print("Anonymous")
                self.signInAnonymously()
            }
        }
        
    }
    
    func openMainView() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.observeCurrentUser()
        UserService.observeCurrentUserSettings()
        nService.clear()
        nService.initialFetch()
        
        if let token = Messaging.messaging().fcmToken {
            let tokenRef = database.child("users/fcmToken/\(uid)")
            tokenRef.setValue(token)
        }
        
        guard let rootVC = window?.rootViewController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        
        if rootVC.childViewControllers.count == 0 {
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()

        } else {
            for i in window?.rootViewController?.view.subviews ?? [] {
                i.isHidden = true
                
                print("REMOVE IT YO!")
            }
            window?.rootViewController?.dismiss(animated: false, completion: {
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()

            })
        }
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//        })
        
        
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            DispatchQueue.main.async {
                guard settings.authorizationStatus == .authorized else { return }
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
        
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Jungle")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
