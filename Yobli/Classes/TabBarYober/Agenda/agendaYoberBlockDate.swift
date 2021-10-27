//
//  agendaYoberBlockDate.swift
//  Yobli
//
//  Created by Brounie on 16/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import FSCalendar

class agendaYoberBlockDate: UIViewController{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var agendaYober: FSCalendar!
    
    // MARK: VARs/LETs
    
    var datesBlocked = [Date]()
    let currenDateTime = Date()
    var daysAvailable = [String]()
    var daysAvailableInt = [Int]()
    var frequency = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agendaYober.delegate = self
        agendaYober.dataSource = self
        agendaYober.allowsMultipleSelection = true
        
        agendaYober.locale = NSLocale.init(localeIdentifier: "es_MX") as Locale
        
        self.updateView()
        
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
            
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    @IBAction func saveChanges(_ sender: Any) {
        
        let user = PFUser.current()!
        
        user["blockedDates"] = datesBlocked
        
        user.saveInBackground {  (success: Bool?, error: Error?) in
            
            if let error = error {
                
                self.sendErrorType(error: error)
                
            }else if success != nil{
                    
                let alert = UIAlertController(title: "ÉXITO", message: "Cambios guardados", preferredStyle: .alert)
                
                //This action is to goBack to the agendaYober after creating the user
                
                let action = UIAlertAction(title: "Continuar", style: .default){ (_) in
                    
                    let goTo = UIStoryboard(name: "TabProfile", bundle: nil).instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
                    
                    goTo.selectedIndex = 0
                    
                    let nav = UINavigationController(rootViewController: goTo )
                    nav.isNavigationBarHidden = true
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = nav
                    
                }
                
                alert.addAction(action)
                    
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        let user = PFUser.current()!
        
        if let newDates = user["blockedDates"] as? [Date]{
            
            datesBlocked = newDates
            
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
        
        for myDate in datesBlocked{
            
            let dateFormatter = DateFormatter()
                
            dateFormatter.dateFormat = "yyyy/MM/dd"
                
                
            let labelDate1 = dateFormatter.string(from: currenDateTime)
            let labelDate2 = dateFormatter.string(from: myDate)
                
            if(labelDate1 == labelDate2){
                
                agendaYober.select(myDate)
                
            }
            
            if( myDate > currenDateTime ){
                
                agendaYober.select(myDate)
                
            }
            
        }
        
        agendaYober.reloadData()
        
    }
    
}

//MARK: FSCALENDAR EXTENSION

extension agendaYoberBlockDate: FSCalendarDelegate, FSCalendarDelegateAppearance, FSCalendarDataSource{
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let result = comparisonOfDate(date: date, calendar)
        
        return result
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        
        return UIColor.lightGray
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        datesBlocked.append(date)
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        if let index = datesBlocked.index(of: date) {
            datesBlocked.remove(at: index)
        }
        
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
            
            let result = comparisonOfDate(date: date, calendar)
            
            if( result == true ){
                        
                let color = returnBlackColor(date: date, calendar)
                
                return color
                        
            }else{
                        
                return UIColor.lightGray
                        
            }
            
        }else{
            
            return UIColor.lightGray
            
        }
            
    }
    
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        return currenDateTime
        
    }
    
    func comparisonOfDate(date: Date, _ calendar: FSCalendar) -> Bool{
        
        if( daysAvailableInt.contains( calendar.gregorian.component(.weekday, from: date) ) ){
            
            if( frequency == "Semanal" ){
                
                if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                    
                    if( calendar.gregorian.component(.weekOfYear, from: currenDateTime) == calendar.gregorian.component(.weekOfYear, from: date) ){
                    
                        return true
                        
                    }else{
                    
                        return false
                    
                    }
                
                }
                
            }else if( frequency ==  "Mensual" ){
                
                if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                    
                    if( calendar.gregorian.component(.month, from: currenDateTime) == calendar.gregorian.component(.month, from: date) ){
                        
                        return true
                        
                    }else{
                    
                        return false
                    
                    }
                
                }
                
            }else if( frequency == "Anual" ){
                
                if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                    
                    return true
                    
                }
                
            }else{
            
                return false
                
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
                return UIColor.black
            } else {
                // User Interface is Light
                return UIColor.white
            }
            
        }else{
            
            return nil
            
        }
        
    }
    
}
