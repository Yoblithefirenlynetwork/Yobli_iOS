//
//  NotificationHandler.swift
//  Yobli
//
//  Created by Brounie on 06/01/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class NotificationHandler{
    
    //MARK: NOTIFICATION SEND
    
    //THIS CLASS IS CALL WHEN YOU START THE APP AND A VALID SESSION IS ACTIVE
    
    class func notificationSend(notificationCreated: Any?) -> UIViewController?{
        
        //Get notification
        
        if let notification = notificationCreated as? [String: AnyObject], let data = notification["aps"] as? [String: AnyObject] {
            
            guard let receiver_id = data["receiver_id"] as? String,
                  let notification_type = data["notification_type"] as? String, let user = PFUser.current() else{
                
                return nil
                
            }
            
            if ( user.objectId == receiver_id ){
                
                switch notification_type {
                case "Reservation":
                    
                    guard let activity_type = data["activity_type"] as? String, let activity_id = data["activity_id"] as? String else{
                        
                        print("This shouldnt happen, everyone ahs this data")
                        
                        break
                    }
                    
                    switch activity_type {
                    
                    case "Course":
                        
                        let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                        
                        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                        
                        tabbar.selectedIndex = 0
                        
                        //VIEW CONTROLLER AND NAV
                        
                        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                            
                            let storyboard2 = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
                            
                            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails {
                                
                                viewcontroller.type = activity_type
                                viewcontroller.activityId = activity_id
                                
                                navigation.pushViewController(viewcontroller, animated: true)
                                
                               return tabbar
                                
                            }
                            
                        }
                        
                        break
                        
                    case "Voluntary":
                        
                        let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                        
                        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                        
                        tabbar.selectedIndex = 0
                        
                        //VIEW CONTROLLER AND NAV
                        
                        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                            
                            let storyboard2 = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
                            
                            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails {
                                
                                viewcontroller.type = activity_type
                                viewcontroller.activityId = activity_id
                                
                                navigation.pushViewController(viewcontroller, animated: true)
                                
                                return tabbar
                                
                            }
                            
                        }
                        
                        break
                    case "Service":
                        
                        let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                        
                        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                        
                        tabbar.selectedIndex = 1
                                
                        return tabbar
                        
                    default:
                        return nil
                    }
                    
                    break
                    
                    
                default:
                    print("Is a normal notification")
                    
                    return nil
                }
                
            }else{
                
                //If this happen, means that the user that press the notification was other than the one that was supposed to received it, this could happen when more than one user share a phone
                
                return nil
                
            }
            
            
        }
        
        return nil
        
    }
    
    //MARK: NOTIFICATION WHEN USER ALREADY IN
    
    //THIS CLASS IS CALL WHEN YOU ARE ALREADY INSIDE THE APP
    
    class func notificationSendWhenUserAlreadyIn( notificationCreated: [AnyHashable : Any] ) -> UIViewController?{
        
        guard let data = notificationCreated["aps"] as? [String: AnyObject] else {
            return nil
        }
        
        guard let receiver_id = data["receiver_id"] as? String,
              let notification_type = data["notification_type"] as? String, let user = PFUser.current() else{
            
            return nil
            
        }
        
        if ( user.objectId == receiver_id ){
            
            switch notification_type {
            case "Reservation":
                
                guard let activity_type = data["activity_type"] as? String, let activity_id = data["activity_id"] as? String else{
                    
                    print("This shouldnt happen, everyone ahs this data")
                    
                    break
                }
                
                switch activity_type {
                
                case "Course":
                    
                    let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                    
                    let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                    
                    tabbar.selectedIndex = 0
                    
                    //VIEW CONTROLLER AND NAV
                    
                    if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                        
                        let storyboard2 = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
                        
                        if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails {
                            
                            viewcontroller.type = activity_type
                            viewcontroller.activityId = activity_id
                            
                            navigation.pushViewController(viewcontroller, animated: true)
                            
                           return tabbar
                            
                        }
                        
                    }
                    
                    break
                    
                case "Voluntary":
                    
                    let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                    
                    let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                    
                    tabbar.selectedIndex = 0
                    
                    //VIEW CONTROLLER AND NAV
                    
                    if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                        
                        let storyboard2 = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
                        
                        if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails {
                            
                            viewcontroller.type = activity_type
                            viewcontroller.activityId = activity_id
                            
                            navigation.pushViewController(viewcontroller, animated: true)
                            
                            return tabbar
                            
                        }
                        
                    }
                    
                    break
                case "Service":
                    
                    let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                    
                    let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                    
                    tabbar.selectedIndex = 1
                            
                    return tabbar
                    
                default:
                    return nil
                }
                
                break
                
                
            default:
                print("Is a normal notification")
                
                return nil
            }
            
        }
        
        //If this happen, means that the user that press the notification was other than the one that was supposed to received it, this could happen when more than one user share a phone
            
        return nil
        
    }
    
    //MARK: NOTIFICATION RESERVATION
    
    class func sendNotificationForReservation(receiverId: String, installationId: String, notificationType: String, activityId: String, activityType: String, activityName: String) {
        
        let params = NSMutableDictionary()
        
        params.setObject(receiverId, forKey: "receiver_installation_id" as NSCopying)
        //params.setObject(installationId, forKey: "installation_id" as NSCopying)
        params.setObject(notificationType, forKey: "notification_type" as NSCopying)
        params.setObject(activityId, forKey: "activity_id" as NSCopying)
        params.setObject(activityType, forKey: "activity_type" as NSCopying)
        params.setObject(activityName, forKey: "activity_name" as NSCopying)
        
        print("receiverId: \(receiverId)")
        //print("installationId: \(installationId)")
        print("notificationType: \(notificationType)")
        print("activityId: \(activityId)")
        print("activityType: \(activityType)")
        print("activityName: \(activityName)")
        
        PFCloud.callFunction(inBackground: "pushNotificationForReservations", withParameters: params as [NSObject : AnyObject], block:{ (results, error)  -> Void in
            
            if let error = error{
                
                print("Error at sending Alert")
                print(error.localizedDescription)
                
            }else{
                
                print("It send the Notification")
                
            }
        })
    }
    
    //MARK: ALERT FOR RESERVATION
    
    class func createAlertForReservation(receiver: PFObject, receiverId: String, notificationType: String, activityId: String, activityType: String, activityName: String, pointerToReservation: PFObject){
        
        let queryYober : PFQuery = PFUser.query()!
        
        queryYober.whereKey("objectId", equalTo:receiverId)
        
        queryYober.getFirstObjectInBackground { (result, error) in
            
            if let error = error{
                
                print("This should happen in createAlertForReservation, but it is a possibility")
                print(error.localizedDescription)
                
            }else if let user = result{
                
                let alert = PFObject(className: "Alert")
                
                alert.setObject(receiver, forKey: "receiver")
                alert.setObject(notificationType, forKey: "notification_type")
                alert.setObject(activityId, forKey: "activity_id")
                alert.setObject(activityType, forKey: "activity_type")
                alert.setObject(activityName, forKey: "activity_name")
                alert.setObject(pointerToReservation, forKey: "pointerToReservation")
                
                switch activityType {
                case "Service":
                    
                    let servicePointer = PFObject.init(withoutDataWithClassName: "Service", objectId: activityId)
                    
                    alert.setObject(servicePointer, forKey: "pointerToService")
                    
                    break
                    
                case "Course":
                    
                    let coursePointer = PFObject.init(withoutDataWithClassName: "Course", objectId: activityId)
                    
                    alert.setObject(coursePointer, forKey: "pointerToCourse")
                    
                    break
                    
                case "Voluntary":
                    
                    let voluntaryPointer = PFObject.init(withoutDataWithClassName: "Voluntary", objectId: activityId)
                    
                    alert.setObject(voluntaryPointer, forKey: "pointerToVoluntary")
                    
                    break
                    
                default:
                    break
                }
                
                alert.saveInBackground { (result, error) in
                    
                    if let error = error{
                        
                        print("Error creating an Alert")
                        print(error.localizedDescription)
                        
                    }else{
                        
                        guard let installationId = user["installationString"] as? String else{
                            
                            print("This is possible, maybe the user doesnt have an installationString")
                            
                            return
                            
                        }
                        
                        self.sendNotificationForReservation(receiverId: receiverId, installationId: installationId, notificationType: notificationType, activityId: activityId, activityType: activityType, activityName: activityName)
                        
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
}
