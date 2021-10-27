//
//  agendaYoberAvailability.swift
//  Yobli
//
//  Created by Brounie on 16/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class agendaYoberAvailability: UIViewController, timeSelectedDelegate{
    
    // MARK: OUTLETS
    
    @IBOutlet var daysCollection: UICollectionView!
    @IBOutlet weak var timesCollection: UITableView!
    
    // MARK: VARs/LETs
    
    let generalDays = ["LUN", "MAR", "MIE", "JUE", "VIE", "SAB", "DOM"]
    
    let generalTimes = ["01:00","02:00","03:00","04:00","05:00","06:00","07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "24:00"]
    
    var selectedDays = [String]()
    var selectedTimes = [String]()
    
    // MARK: MAIN FUNCTION
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        daysCollection.delegate = self
        daysCollection.dataSource = self
        timesCollection.delegate = self
        timesCollection.dataSource = self
        
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func checkFrequency(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "agendaYoberFrequency") as? agendaYoberFrequency
        
        viewController?.selectedTimes = selectedTimes
        viewController?.selectedDays = selectedDays
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    // MARK:OTHER FUNCTIONS
    
    func updateView(){
        
        let user = PFUser.current()!
        
        if let newSelectedDays = user["availableDays"] as? [String]{
            
            selectedDays = newSelectedDays
            
        }else{
            
            selectedDays = []
            
        }
        
        if let newSelectedTimes = user["availableTimes"] as? [String]{
            
            selectedTimes = newSelectedTimes
            
        }else{
            
            selectedTimes = []
            
        }
        
        daysCollection.reloadData()
        timesCollection.reloadData()
        
    }
    
    func timeSelectedYN(stringTime: String, selected: Bool) {
        
        if(selected == true){
            
            if let index = selectedTimes.index(of: stringTime) {
                selectedTimes.remove(at: index)
            }
            
        }else{
            
            selectedTimes.append(stringTime)
            
            selectedTimes = timesOrder(times: selectedTimes)
            
        }
        
        timesCollection.reloadData()
        
    }
    
    //MARK: ORDER SELECTED TIMES
    
    func timesOrder(times: [String]) -> [String]{
        
        var newTimes = [Int]()
        
        newTimes = []
        
        for time in times{
            
            let time2 = time.replacingOccurrences(of: ":00", with: "")
            
            let intValue = Int(time2)
            
            guard let trueValue = intValue else{
                print("Something go wrong")
                return times
            }
            
            newTimes.append(trueValue)
            
        }
        
        let results = newTimes.sorted()
        
        var stringTimes = [String]()
        stringTimes = []
        
        for result in results{
            
            if(result < 10){
                
                let time = "0\(result):00"
                
                stringTimes.append(time)
                
            }else{
                
                let time = "\(result):00"
                
                stringTimes.append(time)
                
            }
            
        }
        
        return stringTimes
        
    }
    
}

// MARK: COLLECTIONVIEW EXTENSION

extension agendaYoberAvailability: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return generalDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = daysCollection.dequeueReusableCell(withReuseIdentifier: "agendaYADaysCell", for: indexPath) as! agendaYADaysCell
        
        cell.dayAgenda.text = generalDays[indexPath.item]
        cell.dayAgenda.layer.cornerRadius = cell.dayAgenda.frame.size.width / 2
        cell.dayAgenda.layer.masksToBounds = true
        cell.dayAgenda.backgroundColor = UIColor.lightGray
        cell.dayAgenda.textColor = UIColor.white
        
        if( selectedDays.contains( generalDays[indexPath.item] ) ){
            
            cell.dayAgenda.textColor = UIColor.lightGray
            cell.dayAgenda.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)

        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if( selectedDays.contains( generalDays[indexPath.item] ) ){
            
            if let index = selectedDays.index(of: generalDays[indexPath.item]) {
                selectedDays.remove(at: index)
            }
            
        }else{
            
            selectedDays.append(generalDays[indexPath.item])
            
        }
        
        daysCollection.reloadData()
        
        
    }
    
    
}

// MARK: TABLEVIEW EXTENSION

extension agendaYoberAvailability: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return generalTimes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = timesCollection.dequeueReusableCell(withIdentifier: "agendaYATimesCell", for: indexPath) as! agendaYATimesCell
        
        cell.timeAgenda.text = generalTimes[indexPath.row]
        cell.timeString = generalTimes[indexPath.row]
        cell.mySelected = false
        cell.selectTime.setImage(UIImage(named: "optionNoSelectIcon"), for: .normal)
        
        cell.delegate = self
        
        if( selectedTimes.contains( generalTimes[indexPath.row] ) ){
            
            cell.selectTime.setImage(UIImage(named: "optionSelectIcon"), for: .normal)
            cell.mySelected = true
            
        }
        
        return cell
        
    }
    
}
