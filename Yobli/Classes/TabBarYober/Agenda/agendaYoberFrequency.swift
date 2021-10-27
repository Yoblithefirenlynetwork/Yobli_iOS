//
//  agendaYoberFrequency.swift
//  Yobli
//
//  Created by Brounie on 16/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class agendaYoberFrequency: UIViewController, frequencySelectedDelegate{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var frequencyCollection: UITableView!
    @IBOutlet weak var addTimeButton: UIButton!
    @IBOutlet weak var subTimeButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    // MARK: VARs/LETs
    
    let generalFrequency = ["Semanal", "Mensual", "Anual"]
    
    var selectedDays = [String]()
    var selectedTimes = [String]()
    var selectedFrequency = ""
    var timeValue = 0.0
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        self.updateView()
        
        frequencyCollection.dataSource = self
        frequencyCollection.delegate = self
        
        addTimeButton.roundCompleteButton()
        
        subTimeButton.roundCompleteButton()
        
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
    
    @IBAction func addTime(_ sender: Any) {
        
        if(timeValue < 8){
            
            timeValue = timeValue + 0.5
            durationLabel.text = String(timeValue) + " horas"
            
        }
        
    }
    
    @IBAction func subTime(_ sender: Any) {
        
        if(timeValue > 0){
            
            timeValue = timeValue - 0.5
            durationLabel.text = String(timeValue) + " horas"
            
        }
        
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        
        let user = PFUser.current()!
        
        user["availableDays"] = selectedDays
        user["availableTimes"] = selectedTimes
        user["availableFrequency"] = selectedFrequency
        user["timeFrequencyBlock"] = String(timeValue) + " horas"
        
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
        
        if let newFrequency = user["availableFrequency"] as? String{
            
            selectedFrequency = newFrequency
            
        }
        
        if let newDuration = user["timeFrequencyBlock"] as? String{
            
            let newDuration2 = newDuration.replacingOccurrences(of: "horas", with: "")
            let newDuration3 = newDuration2.replacingOccurrences(of: " ", with: "")
            
            if let actualDuration = Double(newDuration3) {
                
                timeValue = actualDuration
                self.durationLabel.text = newDuration
                
            } else {
                
                print("Error")
                
            }
            
            
        }else{
            
            self.durationLabel.text = nil
            
        }
        
        frequencyCollection.reloadData()
        
    }
    
    
    func frequencySelectedYN(stringFrequency: String, selected: Bool) {
        
        if(selected == true){
            
            if(selectedFrequency == stringFrequency){
                
                selectedFrequency = ""
                
            }
            
        }else{
            
            selectedFrequency = stringFrequency
            
        }
        
        frequencyCollection.reloadData()
    }
    
}

// MARK: TABLEVIEW EXTENSION

extension agendaYoberFrequency: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return generalFrequency.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = frequencyCollection.dequeueReusableCell(withIdentifier: "agendaYFFrequencyCell", for: indexPath) as! agendaYFFrequencyCell
        
        cell.delegate = self
        cell.frequencyAgenda.text = generalFrequency[indexPath.row]
        cell.frequencyString = generalFrequency[indexPath.row]
        cell.selectedFrequency.setImage(UIImage(named: "optionNoSelectIcon"), for: .normal)
        cell.mySelected = false
        
        if( selectedFrequency == generalFrequency[indexPath.row] ){
            
            cell.selectedFrequency.setImage(UIImage(named: "optionSelectIcon"), for: .normal)
            cell.mySelected = true
            
        }
        
        
        return cell
        
    }
    
}
