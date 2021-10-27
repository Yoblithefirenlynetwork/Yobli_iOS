//
//  agendaYoberCourseList.swift
//  Yobli
//
//  Created by Brounie on 13/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit

class agendaYoberCourseList: UIViewController{
    
    @IBOutlet weak var courseTable: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var course = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        courseTable.delegate = self
        courseTable.dataSource = self
        
        self.dismissWithSwipe()
        
        self.noDataView.isHidden = true
        self.noDataLabel.text = "No tienes cursos disponobles por el momento"
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
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        guard let user = PFUser.current() else{
            self.sendAlert()
            return
        }
        
        self.query(user: user)
        
    }
    
    func query(user: PFObject){
        
        let queryToReservation = PFQuery(className: "Course")
        let date = Date()
        queryToReservation.whereKey("yober", equalTo: user)
        queryToReservation.whereKey("date", greaterThan: date)
        queryToReservation.whereKey("active", equalTo: true)
        
        queryToReservation.findObjectsInBackground { (objects: [PFObject]!, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                
                if objects.count == 0 {
                    self.noDataView.isHidden = false
                }else{
                    self.noDataView.isHidden = true
                    // The find succeeded.
                    self.course = objects
                }
            }
            self.courseTable.reloadData()
        }
    } 
}

extension agendaYoberCourseList: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return course.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = courseTable.dequeueReusableCell(withIdentifier: "agendaCourseCell") as! agendaCourseCell
        
        cell.objects = course[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails
        
        viewController?.type = "Course"
        
        if let objectId = course[indexPath.row].objectId{
            
            viewController?.activityId = objectId
            
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    
}


