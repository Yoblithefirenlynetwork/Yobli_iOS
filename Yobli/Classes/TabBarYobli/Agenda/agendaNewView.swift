//
//  agendaNewView.swift
//  Yobli
//
//  Created by Humberto on 7/17/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FSCalendar

class agendaNewView: UIViewController{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var activitiesTable: UITableView!
    
    @IBOutlet weak var activitiesAgenda: FSCalendar!
    
    // MARK: VARs/LETs
    
    var arrayOfDates = [Date]()
    var activities = [PFObject(className: "Reservation")]
    
    let currenDateTime = Date()
    
    var entry = 0
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        entry = 1
        
        activitiesTable.delegate = self
        activitiesTable.dataSource = self
        
        activitiesAgenda.delegate = self
        activitiesAgenda.dataSource = self
        
        activitiesAgenda.locale = NSLocale.init(localeIdentifier: "es_MX") as Locale
        
        activitiesAgenda.allowsMultipleSelection = true
            
    }
        
    override func viewDidAppear(_ animated: Bool) {
        
        if(entry < 1){
            self.updateView()
        }
        entry = 0

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    // MARK: OTHER FUNCTIONS
        
    func updateView(){
    
        arrayOfDates = []
        activities = []
        
        self.getRegistrations()
//        guard let user = PFUser.current() else{
//
//            self.sendAlert()
//
//            return
//
//        }
//
//        if let newEventsArray = user["registerEvents"] as? [PFObject]{
//
//            for object in newEventsArray {
//
//                if let id = object.objectId {
//
//                    self.getRegistrations(keyFromUser: id)
//
//                }
//            }
//        }
    }
    
    func getRegistrations(){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
    
        let queryReservations = PFQuery(className: "Reservation")
        queryReservations.whereKey("user", contains: user.objectId ?? "")
        queryReservations.order(byAscending: "date")
        queryReservations.whereKey("active", equalTo: true)
        queryReservations.whereKey("grade", equalTo: false)
        queryReservations.includeKeys(["yober"])
        
        queryReservations.findObjectsInBackground { (objects, error) in
            
            if let error = error {
                // Log details of the failure
                
                let nsError = error as NSError
                
                print(nsError.code)
                self.sendErrorTypeExpected(error: error)
                
            } else if let objects = objects {
                // The find succeeded.
                
                for object in objects {
                 
                    let type = object["type"] as? String
                    let date = object["date"] as? Date
                    
                    if type == "Voluntary" && date ?? Date() < Date() {
                        print("voluntariado no agregado: \(object.debugDescription)")
                    }else{
                        self.activities.append(object)
                    }
                    
                    if let myNewDate = object["date"] as? Date{
                                
                        if type == "Voluntary" && date ?? Date() < Date() {
                            print("voluntariado no agregado for fecha: \(object.debugDescription)")
                        }else{
                            self.arrayOfDates.append(myNewDate)
                        }
                    }
                }
                
                self.activitiesAgenda.reloadData()
                self.activitiesTable.reloadData()
                
            }
            
        }
        
    }
    
}

// MARK: TABLEVIEW EXTENSION

extension agendaNewView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
        
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        print("activities.count: \(activities.count)")
        return activities.count
            
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = activitiesTable.dequeueReusableCell(withIdentifier: "agendaListTableCell") as! agendaListTableCell
            
        cell.objects = activities[indexPath.row]
            
        return cell
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activitiesTable.deselectRow(at: indexPath, animated: false)
        
        guard let dateOfActivity = activities[indexPath.row]["date"] as? Date, let activityType = activities[indexPath.row]["type"] as? String, let activityId = activities[indexPath.row]["activityId"] as? String else{
            
            print("This shouldn't happen")
            
            return
            
        }
        
        let currentDate = Date()
        
        if( currentDate > dateOfActivity ){
            
            if(activityType != "Voluntary"){
            
                let alert = UIAlertController(title: "ATENCIÓN", message: "El evento seleccionado ya terminó, puede calificarlo o visitarlo", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Cerrar", style: .cancel)
                
                let action2 = UIAlertAction(title: "Calificar", style: .default){ (_) in
                    
                    self.sendToGrade(activity: self.activities[indexPath.row])
                    
                }
                
                let action3 = UIAlertAction(title: "Visitar", style: .default){ (_) in
                    
                    self.sendToActivity(activityType: activityType, activityId: activityId)
                    
                }
                
                alert.addAction(action)
                alert.addAction(action2)
                alert.addAction(action3)
                    
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }else{
            
            self.sendToActivity(activityType: activityType, activityId: activityId)
            
        }
        
    }
        
}

// MARK: FSCALENDAR EXTENSION

extension agendaNewView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        var count = 0
        
        for myDate in arrayOfDates{
            
            let labelDate1 = dateFormatter.string(from: myDate)
            let labelDate2 = dateFormatter.string(from: date)
            
            if(labelDate1 == labelDate2){
                
                count = count + 1
                
            }
                    
        }
        
        return count
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        var colors = [UIColor]()
        
        if( currenDateTime > date ){
            
            //colors.append(appearance.selectionColor)
            colors.append( UIColor.clear)
            
            return colors
                
        } else {
                
            var x = 0
                
            for myDate in arrayOfDates{
                    
                let dateFormatter = DateFormatter()
                    
                dateFormatter.dateFormat = "yyyy/MM/dd"
                    
                    
                let labelDate1 = dateFormatter.string(from: myDate)
                let labelDate2 = dateFormatter.string(from: date)
                    
                if(labelDate1 == labelDate2){
                            
                    let category = activities[x]["type"] as! String
                                
                    if(category == "Voluntary"){
                        
                        colors.append( UIColor.init(red: 255/255, green: 223/255, blue: 0, alpha: 1) )
                        
                    }else if(category == "Course"){
                                
                        colors.append( UIColor.init(red: 255/255, green: 0, blue: 149/255, alpha: 1) )
                                    
                    }else if(category == "Service"){
                            
                        colors.append( UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1) )
                                    
                    }
                }
                x = x + 1
            }
        }
            
        return colors
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        return false
        
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        return currenDateTime
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        
        let dateFormatter = DateFormatter()
            
        dateFormatter.dateFormat = "yyyy/MM/dd"
            
            
        let labelDate1 = dateFormatter.string(from: currenDateTime)
        let labelDate2 = dateFormatter.string(from: date)
            
        if(labelDate1 == labelDate2){
            
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
            
            
        }else{
            
            return nil
            
        }
        
    }
    
}

extension agendaNewView{
    
    func sendToGrade(activity: PFObject){
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "agendaActivityGrade") as? agendaActivityGrade
        
        viewController?.getReservation = activity
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    func sendToActivity(activityType: String, activityId: String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
        
        tabbar.selectedIndex = 2
        
        switch activityType {
        
        case "Service":
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreService") as? exploreService {
                    
                    viewcontroller.serviceId = activityId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = tabbar
                    
                }
                
            }
            
            break
            
        case "Voluntary":
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreVoluntary") as? exploreVoluntary {
                    
                    viewcontroller.voluntaryId = activityId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = tabbar
                    
                }
                
            }
            
            break
            
        case "Course":
            
            //VIEW CONTROLLER AND NAV
            
            if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                
                let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
                
                if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreCourse") as? exploreCourse {
                    
                    viewcontroller.courseId = activityId
                    
                    navigation.pushViewController(viewcontroller, animated: true)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = tabbar
                    
                }
                
            }
            
            break
            
        default:
            print("This should not happen")
            break
        }
        
    }
    
}
