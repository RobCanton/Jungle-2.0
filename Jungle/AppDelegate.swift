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

var listeningDict = [String:Bool]() {
    didSet {
        print("NEWFOUNDLAND: \(listeningDict)")
    }
}
var currentUser:User?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override  for customization after application launch.
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

        //try! Auth.auth().signOut()
        let authHandler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print("WE ARE HERE DUDE")
                let ref = firestore.collection("users").document(user.uid)
                ref.getDocument { snapshot, error in
                    if let snapshot = snapshot {
                        let data = snapshot.data()
                        guard let username = data?["username"] as? String else { return }
                        currentUser = User(uid: user.uid, username: username)
                        print("GOT THE USERNAME: \(username)")
                        self.openMainView()
                    }
                }

            } else {
                self.signInAnonymously()
            }
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
            if user != nil && error == nil {
                self.openMainView()
            }
        }
    }
    
    func openMainView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()
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

