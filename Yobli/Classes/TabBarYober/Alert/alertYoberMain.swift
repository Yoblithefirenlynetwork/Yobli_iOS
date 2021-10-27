//
//  alertYoberMain.swift
//  Yobli
//
//  Created by Brounie on 25/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class alertYoberMain: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var alertTable: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var titleDataLabel: UILabel!
    
    //MARK: VARs/LETs
    
    var alertArray = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertTable.delegate = self
        alertTable.dataSource = self
        
        self.noDataView.isHidden = true
        self.titleDataLabel.text = "Aún no tienes notificaciones"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
            
            self.sendAlert()
            
        }
        
        self.getAlerts()
        
    }
    
    //MARK: GET ALERTS
    
    func getAlerts(){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        let queryAlerts = PFQuery(className: "Alert")
        
        queryAlerts.whereKey("receiver", equalTo: user)
        queryAlerts.includeKeys(["pointerToService", "pointerToCourse", "pointerToVoluntary"])
        
        queryAlerts.findObjectsInBackground { (alerts, error) in
            
            if let error = error{
                
                self.sendErrorTypeExpected(error: error)
                
            }else if let alerts = alerts{
                
                if alerts.count == 0 {
                    self.noDataView.isHidden = false
                }else{
                    // The find succeeded.
                    self.alertArray = alerts
                    self.noDataView.isHidden = true
                }
                
                
                
                /*
                
                if( alerts.count > 0 ){
                
                    self.tabBarController?.tabBar.items?[2].badgeValue = "\(alerts.count)"
                    
                }
 
                 */
                
                self.alertTable.reloadData()
                
            }
            
        }
        
        
    }
    
}

// MARK: EXTENSION TABLEVIEW

extension alertYoberMain: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return alertArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = alertTable.dequeueReusableCell(withIdentifier: "alertYoberMainCell") as! alertYoberMainCell
            
        guard let type = alertArray[indexPath.row]["notification_type"] as? String else{
            return cell
        }
            
        switch type {
        case "Reservation":
            
            guard let activity_type = alertArray[indexPath.row]["activity_type"] as? String, let activity_name = alertArray[indexPath.row]["activity_name"] as? String else{
                break
            }
            
            switch activity_type {
            case "Course":
                
                if let pointerToCourse:PFObject = alertArray[indexPath.row]["pointerToCourse"] as? PFObject{
                    
                    if let imageInformation = pointerToCourse["logo"] as? PFFileObject{
                    
                        imageInformation.getDataInBackground{
                            
                            (imageData: Data?, error: Error?) in
                            if let error = error{
                                print(error.localizedDescription)
                            }else if let imageData = imageData{
                                
                                let image = UIImage(data: imageData)
                                cell.notificationImage.image = image
                            }
                            
                        }
                        
                    }
                    
                }
                
                cell.notificationImage.roundCompleteImage()
                cell.notificationImage.roundCompleteImageColor()
                cell.notificationLabel.text = "Tienes una nueva reservación en el curso: \(activity_name)"
                break
            case "Service":
                
                if let pointerToCourse:PFObject = alertArray[indexPath.row]["pointerToService"] as? PFObject{
                    
                    if let imageInformation = pointerToCourse["logo"] as? PFFileObject{
                    
                        imageInformation.getDataInBackground{
                            
                            (imageData: Data?, error: Error?) in
                            if let error = error{
                                print(error.localizedDescription)
                            }else if let imageData = imageData{
                                
                                let image = UIImage(data: imageData)
                                
                                cell.notificationImage.image = image
                            }
                            
                        }
                        
                    }
                    
                }
                
                cell.notificationImage.roundCompleteImage()
                cell.notificationImage.roundCompleteImageColor()
                cell.notificationLabel.text = "Tienes un nuevo cliente para el servicio: \(activity_name)"
                break
            case "Voluntary":
                
                if let pointerToCourse:PFObject = alertArray[indexPath.row]["pointerToVoluntary"] as? PFObject{
                    
                    if let imageInformation = pointerToCourse["logo"] as? PFFileObject{
                    
                        imageInformation.getDataInBackground{
                            
                            (imageData: Data?, error: Error?) in
                            if let error = error{
                                print(error.localizedDescription)
                            }else if let imageData = imageData{
                                
                                let image = UIImage(data: imageData)
                                
                                cell.notificationImage.image = image
                            }
                            
                        }
                        
                    }
                    
                }
                
                cell.notificationImage.roundCompleteImage()
                cell.notificationImage.roundCompleteImageColor()
                cell.notificationLabel.text = "Tienes un nuevo voluntario para: \(activity_name)"
                break
            default:
                break
            }
            
            break
            
        case "Cancelation":
            break
        default:
            print("This is only default")
            break
        }
            
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let type = alertArray[indexPath.row]["notification_type"] as? String else{
            
            print("Is not working in notification_type")
            
            return
        }
            
        switch type {
        case "Reservation":
            
            guard let pointerToReservation = alertArray[indexPath.row]["pointerToReservation"] as? PFObject, let activity_type = alertArray[indexPath.row]["activity_type"] as? String, let activity_id = alertArray[indexPath.row]["activity_id"] as? String else{
                
                print("This shouldnt happen, everyone ahs this data")
                
                break
            }
            
            switch activity_type {
            case "Course":
                
//                let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
//
//                let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
//
//                tabbar.selectedIndex = 0
//
//                //VIEW CONTROLLER AND NAV
//
//                if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
//
//                    let storyboard2 = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
//
//                    if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails {
//
//                        viewcontroller.type = activity_type
//                        viewcontroller.activityId = activity_id
//
//                        navigation.pushViewController(viewcontroller, animated: true)
//
//                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//                        appDelegate.window?.rootViewController = tabbar
//
//                    }
//
//                }
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AlertDetailViewController") as? AlertDetailViewController

                viewController?.type = "Course"
                viewController?.activityId = activity_id
                viewController?.pointerToReservation = pointerToReservation.objectId ?? ""
                
                print("activity_id: \(activity_id)")
                print("pointerToReservation: \(pointerToReservation)")
                self.navigationController?.pushViewController(viewController!, animated: true)
                
                break
                
            case "Voluntary":
                
//                let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
//
//                let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
//
//                tabbar.selectedIndex = 0
//
//                //VIEW CONTROLLER AND NAV
//
//                if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
//
//                    let storyboard2 = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
//
//                    if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails {
//
//                        viewcontroller.type = activity_type
//                        viewcontroller.activityId = activity_id
//
//                        navigation.pushViewController(viewcontroller, animated: true)
//
//                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//                        appDelegate.window?.rootViewController = tabbar
//
//                    }
//
//                }
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AlertDetailViewController") as? AlertDetailViewController

                viewController?.type = "Voluntary"
                viewController?.activityId = activity_id
                viewController?.pointerToReservation = pointerToReservation.objectId ?? ""
                
                print("activity_id: \(activity_id)")
                print("pointerToReservation: \(pointerToReservation)")
                self.navigationController?.pushViewController(viewController!, animated: true)
                
                break
            case "Service":
                
//                let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
//                let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
//                tabbar.selectedIndex = 1
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.window?.rootViewController = tabbar
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AlertDetailViewController") as? AlertDetailViewController

                viewController?.type = "Service"
                viewController?.activityId = activity_id
                viewController?.pointerToReservation = pointerToReservation.objectId ?? ""
                
                print("activity_id: \(activity_id)")
                print("pointerToReservation: \(pointerToReservation)")


                self.navigationController?.pushViewController(viewController!, animated: true)
                
                break
            default:
                break
            }
            
            break
            
        case "Cancelation":
            break
        default:
            print("This is only default")
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at: indexPath)
            
        return UISwipeActionsConfiguration(actions: [delete])
        
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, completion) in
            self.updateTable(position: indexPath.row)
            completion(true)
        }
        
        action.backgroundColor = UIColor.systemRed
        
        return action
        
    }
    
    //UPDATE TABLE WHEN DOING DELETE
    
    func updateTable(position: Int){
                
        alertArray[position].deleteInBackground { (result, error) in
                        
            if let error = error{
                            
                self.sendErrorType(error: error)
                            
            }else{
                            
                self.getAlerts()
                            
            }
                        
        }
        
    }
    
    
}
