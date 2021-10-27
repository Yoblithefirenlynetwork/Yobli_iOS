//
//  agendaYoberMain.swift
//  Yobli
//
//  Created by Brounie on 25/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FSCalendar

class agendaYoberMain: UIViewController{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var courseButton: UIButton!
    @IBOutlet weak var voluntaryButton: UIButton!
    @IBOutlet weak var yoberAgenda: FSCalendar!
    
    // MARK: VARs/LETs
    
    var datesBlocked = [Date]()
    var datesCourse = [Date]()
    var datesService = [Date]()
    var daysAvailable = [String]()
    var daysAvailableInt = [Int]()
    var frequency = ""
    var datesVoluntary = [Date]()
    let currenDateTime = Date()
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        yoberAgenda.delegate = self
        yoberAgenda.dataSource = self
        yoberAgenda.allowsMultipleSelection = true
        
        yoberAgenda.locale = NSLocale.init(localeIdentifier: "es_MX") as Locale
        
        self.updateView()
        
        serviceButton.roundCompleteButton()
        courseButton.roundCompleteButton()
        voluntaryButton.roundCompleteButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
            
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func checkServices(_ sender: Any) {
        
//        let goTo = UIStoryboard(name: "TabProfile", bundle: nil).instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
//        
//        goTo.selectedIndex = 1
//        
//        let nav = UINavigationController(rootViewController: goTo )
//        nav.isNavigationBarHidden = true
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        appDelegate.window?.rootViewController = nav
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "agendaYoberServicesList") as? agendaYoberServicesList
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func checkCourses(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "agendaYoberCourseList") as? agendaYoberCourseList
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func checkVoluntary(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "agendaYoberVoluntaryList") as? agendaYoberVoluntaryList
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func editAgenda(_ sender: Any) {
        
        let selectOption = UIAlertController()
        
        selectOption.addAction(UIAlertAction(title: "Editar Disponibilidad", style: .default, handler: {(action:UIAlertAction) in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "agendaYoberAvailability") as? agendaYoberAvailability
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }))
        
        selectOption.addAction(UIAlertAction(title: "Bloquear un día", style: .default, handler: {(action:UIAlertAction) in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "agendaYoberBlockDate") as? agendaYoberBlockDate
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }))
        
        selectOption.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(selectOption, animated: true, completion: nil)
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
        }
        
        if let newBDates = user["blockedDates"] as? [Date]{
            
            datesBlocked = newBDates
        }
        
        if let newTsAvailable = user["availableDays"] as? [String]{
            
            daysAvailable = newTsAvailable
            daysAvailableInt = []
            
            for myTime in daysAvailable{
                
                if(myTime == "LUN"){
                    
                    daysAvailableInt.append(2)
                    
                }else if(myTime == "MAR"){
                    
                    daysAvailableInt.append(3)
                    
                }else if(myTime == "MIE"){
                    
                    daysAvailableInt.append(4)
                    
                }else if(myTime == "JUE"){
                    
                    daysAvailableInt.append(5)
                    
                }else if(myTime == "VIE"){
                    
                    daysAvailableInt.append(6)
                    
                }else if(myTime == "SAB"){
                    
                    daysAvailableInt.append(7)
                    
                }else if(myTime == "DOM"){
                    
                    daysAvailableInt.append(1)
                    
                }
                
            }
            
        }
        
        if let newFrequency = user["availableFrequency"] as? String{
            
            frequency = newFrequency
            
        }
        
        yoberAgenda.reloadData()
        
        self.updateDatesCV(name: "Course", yober: user)
        self.updateDatesCV(name: "Voluntary", yober: user)
        self.updateReserveService(yober: user)
        
    }
    
    //So it can be easier to update the Dates without more code than neccesary
    
    func updateDatesCV(name: String, yober: PFObject){
        
        var newArrayOfDates = [Date]()
        
        let objectLook = PFQuery(className: name)
        
        objectLook.whereKey("yober", equalTo: yober)
        objectLook.whereKey("active", equalTo: true)
        
        objectLook.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                
                for object in objects{
                    
                    if let newDate = object["date"] as? Date{
                        
                        newArrayOfDates.append( newDate )
                        
                    }
                    
                }
                
                if( name == "Course" ){
                    
                    self.datesCourse = newArrayOfDates
                    
                    self.yoberAgenda.reloadData()
                    
                }else if( name == "Voluntary" ){
                    
                    self.datesVoluntary = newArrayOfDates
                    
                    self.yoberAgenda.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    func updateReserveService(yober: PFObject){
        
        var newArrayOfDates = [Date]()
        
        let objectLook = PFQuery(className: "Reservation")
        
        objectLook.whereKey("yober", equalTo: yober)
        objectLook.whereKey("type", equalTo: "Service")
        objectLook.whereKey("active", equalTo: true)
        
        objectLook.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                
                for object in objects{
                    
                    if let newDate = object["date"] as? Date{
                        
                        newArrayOfDates.append( newDate )
                        
                    }
                    
                }
                
                self.datesService = newArrayOfDates
                    
                self.yoberAgenda.reloadData()
                
            }
            
        }
        
    }
    
}

// MARK: FSCALENDAR EXTENSION

extension agendaYoberMain: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        return false
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        return false
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let dateFormatter = DateFormatter()
            
        dateFormatter.dateFormat = "yyyy/MM/dd"
            
            
        let labelDate1 = dateFormatter.string(from: currenDateTime)
        let labelDate2 = dateFormatter.string(from: date)
            
        if(labelDate1 == labelDate2){
            
            if ( datesBlocked.contains(date) ){
                
                return UIColor.lightGray
                
            }
            
            return UIColor.black
            
        }
        
        if( date > currenDateTime ){
            
            if ( datesBlocked.contains(date) ){
                
                return UIColor.lightGray
                
            }else{
                
                if( daysAvailableInt.contains( calendar.gregorian.component(.weekday, from: date) ) ){
                    
                    if( frequency == "Semanal" ){
                        
                        if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                            
                            if( calendar.gregorian.component(.weekOfYear, from: currenDateTime) == calendar.gregorian.component(.weekOfYear, from: date) ){
                            
                                let color = returnBlackColor(date: date, calendar)
                                
                                return color
                            
                            }
                        
                        }else if(compareDates(actualDate: date) == true){
                            
                            if self.traitCollection.userInterfaceStyle == .dark {
                                // User Interface is Dark
                                return UIColor.white
                            } else {
                                // User Interface is Light
                                return UIColor.black
                            }
                            
                        }else{
                            
                            return UIColor.lightGray
                            
                        }
                        
                    }else if( frequency ==  "Mensual" ){
                        
                        if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                            
                            if( calendar.gregorian.component(.month, from: currenDateTime) == calendar.gregorian.component(.month, from: date) ){
                                
                                let color = returnBlackColor(date: date, calendar)
                                
                                return color
                                
                            }
                        
                        }else if(compareDates(actualDate: date) == true){
                            
                            if self.traitCollection.userInterfaceStyle == .dark {
                                // User Interface is Dark
                                return UIColor.white
                            } else {
                                // User Interface is Light
                                return UIColor.black
                            }
                            
                        }else{
                            
                            return UIColor.lightGray
                            
                        }
                        
                    }else if( frequency == "Anual" ){
                        
                        if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                            
                            let color = returnBlackColor(date: date, calendar)
                            
                            return color
                            
                        }
                        
                    }
                    
                    
                }else if(compareDates(actualDate: date) == true){
                    
                    if self.traitCollection.userInterfaceStyle == .dark {
                        // User Interface is Dark
                        return UIColor.white
                    } else {
                        // User Interface is Light
                        return UIColor.black
                    }
                    
                }else{
                    
                    return UIColor.lightGray
                    
                }
                
                
            }
            
        }
        
        return UIColor.lightGray
            
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        var count = 0
        
        for myDate in datesService{
            
            let labelDate1 = dateFormatter.string(from: myDate)
            let labelDate2 = dateFormatter.string(from: date)
            
            if(labelDate1 == labelDate2){
                
                count = count + 1
                
            }
                    
        }
        
        for myDate in datesCourse{
            
            let labelDate1 = dateFormatter.string(from: myDate)
            let labelDate2 = dateFormatter.string(from: date)
            
            if(labelDate1 == labelDate2){
                
                count = count + 1
                
            }
                    
        }
        
        for myDate in datesVoluntary{
            
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
            
            colors.append(appearance.selectionColor)
            
            return colors
                
        } else {
                
            for myDate in datesService{
                    
                let dateFormatter = DateFormatter()
                    
                dateFormatter.dateFormat = "yyyy/MM/dd"
                
                let labelDate1 = dateFormatter.string(from: myDate)
                let labelDate2 = dateFormatter.string(from: date)
                    
                if(labelDate1 == labelDate2){
                    
                    colors.append( UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1) )
                            
                }
                        
            }
            
            for myDate in datesCourse{
                    
                let dateFormatter = DateFormatter()
                    
                dateFormatter.dateFormat = "yyyy/MM/dd"
                
                let labelDate1 = dateFormatter.string(from: myDate)
                let labelDate2 = dateFormatter.string(from: date)
                    
                if(labelDate1 == labelDate2){
                
                    colors.append( UIColor.init(red: 255/255, green: 0, blue: 149/255, alpha: 1) )
                            
                }
                        
            }
            
            for myDate in datesVoluntary{
                    
                let dateFormatter = DateFormatter()
                    
                dateFormatter.dateFormat = "yyyy/MM/dd"
                
                let labelDate1 = dateFormatter.string(from: myDate)
                let labelDate2 = dateFormatter.string(from: date)
                    
                if(labelDate1 == labelDate2){
                    
                    colors.append( UIColor.init(red: 255/255, green: 223/255, blue: 0, alpha: 1) )
                            
                }
                        
            }
                
        }
            
        return colors
        
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        return currenDateTime
        
    }
    
    func compareDates(actualDate: Date) -> Bool{
        
        let dateFormatter = DateFormatter()
            
        dateFormatter.dateFormat = "yyyy/MM/dd"
           
        for myDate in datesCourse{
            
            let labelDate1 = dateFormatter.string(from: myDate)
            let labelDate2 = dateFormatter.string(from: actualDate)
                
            if(labelDate1 == labelDate2){
                
                return true
                
            }
            
        }
            
        for myDate in datesVoluntary{
            
            let labelDate1 = dateFormatter.string(from: myDate)
            let labelDate2 = dateFormatter.string(from: actualDate)
                
            if(labelDate1 == labelDate2){
                
                return true
                
            }
            
        }
        
        for myDate in datesService{
            
            let labelDate1 = dateFormatter.string(from: myDate)
            let labelDate2 = dateFormatter.string(from: actualDate)
                
            if(labelDate1 == labelDate2){
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    func returnBlackColor(date: Date, _ calendar: FSCalendar) -> UIColor{
        
        switch calendar.gregorian.component(.weekday, from: date) {
        
        case 1:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 2:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 3:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 4:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 5:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 6:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 7:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        default:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
            
        }
        
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
