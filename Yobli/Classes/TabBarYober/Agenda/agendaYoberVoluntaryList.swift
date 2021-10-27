//
//  agendaYoberVoluntaryList.swift
//  Yobli
//
//  Created by Brounie on 13/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit

class agendaYoberVoluntaryList: UIViewController{
    
    @IBOutlet weak var voluntaryTable: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var voluntary = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        voluntaryTable.delegate = self
        voluntaryTable.dataSource = self
        
        self.dismissWithSwipe()
        self.noDataView.isHidden = true
        self.noDataLabel.text = "No tienes voluntariados disponobles por el momento"
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
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            return
            
        }
        
        self.query(yober: user)
        
    }
    
    func query(yober: PFObject){
        
        let queryToReservation = PFQuery(className: "Voluntary")
        
        let date = Date()
        queryToReservation.whereKey("yober", equalTo: yober)
        queryToReservation.whereKey("date", greaterThan: date)
        queryToReservation.whereKey("active", equalTo: true)
        
        queryToReservation.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                if objects.count == 0 {
                    self.noDataView.isHidden = false
                }else{
                    self.noDataView.isHidden = true
                    self.voluntary = objects
                }
            }
            self.voluntaryTable.reloadData()
        }
    }
    
}

extension agendaYoberVoluntaryList: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return voluntary.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = voluntaryTable.dequeueReusableCell(withIdentifier: "agendaVoluntaryCell") as! agendaVoluntaryCell
        
        cell.objects = voluntary[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails
        
        viewController?.type = "Voluntary"
        
        if let objectId = voluntary[indexPath.row].objectId{
            
            viewController?.activityId = objectId
            
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    
}
