//
//  AppDelegate.swift
//  Yobli
//
//  Created by Humberto on 7/6/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import CoreData
import Parse
import FBSDKCoreKit
import Firebase
import IQKeyboardManagerSwift
import UserNotifications
import FirebaseMessaging

// Swift
//
// AppDelegate.swift
import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: - FireBase
        
        FirebaseApp.configure()
        
        //MARK: - PushNotification FireBase
        
//        UNUserNotificationCenter.current().delegate = self
//
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in})
//
//        application.registerForRemoteNotifications()

        //Messaging.messaging().subscribe(toTopic: "tutorial") // notificaciones solo a los que tengan este topic
//
        //Messaging.messaging().delegate = self
        
        
        //MARK: - PuschNotification Parse
        
        self.registerForPushNotifications()
        
        
        //MARK: - Facebook
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        //
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "BrounieApp"
            $0.clientKey = "C4suYZKkyRMYPGR7fEae"
            //$0.server = "https://yobli.com/parse"
            //$0.server = "https://yobli.brounieapps.com/parse"
            $0.server = "https://parse.yobli.com/parse"
            $0.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: parseConfig)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        IQKeyboardManager.shared.enable = true
        
        if PFUser.current() != nil {
            
            if Auth.auth().currentUser != nil {
                
                PFUser.current()?.fetchInBackground(block: { (object, error) in
                    
                    if error == nil{
                        
                        let user = PFUser.current()!
                        
                        guard let isYoberMain = user["yoberMain"] as? Bool else{
                            return
                        }
                        
                        if(isYoberMain == true){
                            
                            // Code to execute if user is logged in
                            
                            let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as? UITabBarController
                            
                            viewController?.selectedIndex = 4

                            self.window?.rootViewController = viewController
                            self.window?.makeKeyAndVisible()
                            
                            let notificationOption = launchOptions?[.remoteNotification]

                            let result = NotificationHandler.notificationSend(notificationCreated: notificationOption)
                            
                            if result != nil{
                                
                                self.window?.rootViewController = result
                                
                            }
                            
                        }else{
                            
                            // Code to execute if user is logged in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as? UITabBarController

                            self.window?.rootViewController = viewController
                            self.window?.makeKeyAndVisible()
                            
                            let notificationOption = launchOptions?[.remoteNotification]

                            let result = NotificationHandler.notificationSend(notificationCreated: notificationOption)
                            
                            if result != nil{
                                
                                self.window?.rootViewController = result
                                
                            }
                            
                        }
                        
                    }else{
                        
                        PFUser.logOut()
                        
                    }
                    
                })

            }else{
                
                PFUser.logOut()
                
            }

        } else {
            // Default screen.
        }
        
        return true
        
    }
    
    //Facebook
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return ApplicationDelegate.shared.application(
            
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
            
        )
        
    }
    
    //Facebook AND Redirect from created URL
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        //Facebook
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        //
        
        print("Is entering here")
        
        if( ApplicationDelegate.shared.application(
            
            app,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
            
        ) == true ){
            
            return true
            
        } else {
            
            print(url)
            
            let result = LinkHandler.goTo(url: url)
            
            if result != nil {
                
                window?.rootViewController = result
                
                return true
                
            }else {
            
                return false
                
            }
        }
    }

    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool{

        print("Enter here URL Univeral Link")

        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }

        let result = LinkHandler.goTo(url: incomingURL)

        if result != nil {

            window?.rootViewController = result

            return true

        }else {

            return false

        }
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
        AppEvents.activateApp() //Facebook
        
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
        let container = NSPersistentContainer(name: "Yobli")
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
    
    //Notification application func
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if PFUser.current() != nil {

            if Auth.auth().currentUser != nil {

                // In all API requests, call the global error handler, e.g.
                PFUser.current()?.fetchInBackground(block: { (object, error) in

                    if error == nil{

                        let result = NotificationHandler.notificationSendWhenUserAlreadyIn(notificationCreated: userInfo)

                        if result != nil{

                            self.window?.rootViewController = result

                        }else{
                            completionHandler(.failed)
                        }

                        PFPush.handle(userInfo)

                    }else{

                        PFUser.logOut()

                    }

                })

            }else{

                PFUser.logOut()

            }

        } else {
            // Default screen.
        }

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let installation = PFInstallation.current()

        installation?.setDeviceTokenFrom(deviceToken)

        installation?.saveInBackground()

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        let nsError = error as NSError

        if nsError.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }

    }
    
    func registerForPushNotifications() {

      //1
      UNUserNotificationCenter.current()
        //2
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in

            //3
            print("Permission granted: \(granted)")

            guard granted else { return }
            self.getNotificationSettings()

        }

    }
    
    func getNotificationSettings() {

      UNUserNotificationCenter.current().getNotificationSettings { settings in

        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }

      }

    }
    
}





//MARK: - UNUserNotificationCenterDelegate
//
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert, .badge, .sound])
    }
}
//
////MARK: - MessagingDelegate
//
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        debugPrint("FCM token: \(String(describing: fcmToken))")
        let token = fcmToken

        print("token: \(token ?? "")")
    }

}

