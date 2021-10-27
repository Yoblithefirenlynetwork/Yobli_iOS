//
//  serviceYoberServicesViewController.swift
//  Yobli
//
//  Created by Rodrigo Rivera on 29/03/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import UIKit
import Parse

class serviceYoberServicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listTableVIew: UITableView!
    @IBOutlet weak var noInfoView: UIView!
    @IBOutlet weak var noInfoLabel: UILabel!
    
    var reservation = [PFObject]()
    var activityIdArray = [String]()
    var serviceDateArray = [Date]()
    
    var type = ""
    var titleString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listTableVIew.delegate = self
        self.listTableVIew.dataSource = self
        
        self.initStrings()
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            return
            
        }
        
        self.getReservations(user: user)
        
        self.noInfoView.alpha = 0.0
    }
    

    //MARK: - initStrings
    
    func initStrings() {
        
        self.titleLabel.text = self.titleString
        self.noInfoLabel.text = "No hay información"
    }
    
    //MARK: - Methods
    
    func getReservations(user: PFObject){
        
        self.activityIdArray = []
        self.reservation = []
        self.serviceDateArray = []
        
        if self.type == "Course" {
            
            let queryToReservation = PFQuery(className: "Reservation")
            
            queryToReservation.whereKey("yober", equalTo: user)
            queryToReservation.whereKey("type", equalTo: self.type)
            //queryToReservation.whereKey("active", equalTo: true)
            queryToReservation.includeKey("user")
            
            queryToReservation.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    // The find succeeded.
                    for object in objects {
                        
                        let activityId = object["activityId"] as? String
                        
                        if self.activityIdArray.contains(activityId ?? "") {
                            print("ya lo tiene")
                        }else{
                            self.activityIdArray.append(activityId ?? "")
                            self.reservation.append(object)
                        }
                    }
                }
                if self.reservation.count > 0 {
                    self.listTableVIew.reloadData()
                    self.noInfoView.alpha = 0.0
                }else{
                    self.noInfoView.alpha = 1.0
                }
            }
            
        }else if self.type == "Service" {
            
            let queryToReservation = PFQuery(className: "Reservation")
            
            queryToReservation.whereKey("yober", equalTo: user)
            queryToReservation.whereKey("type", equalTo: self.type)
            //queryToReservation.whereKey("active", equalTo: true)
            queryToReservation.includeKey("user")
            
            queryToReservation.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    // The find succeeded.
                    for object in objects {
                        
                        let serviceDate = object["date"] as? Date
                        
                        if self.serviceDateArray.contains(serviceDate ?? Date()) {
                            print("ya lo tiene")
                        }else{
                            self.serviceDateArray.append(serviceDate ?? Date())
                            self.reservation.append(object)
                        }
                    }
                }
                if self.reservation.count > 0 {
                    self.listTableVIew.reloadData()
                    self.noInfoView.alpha = 0.0
                }else{
                    self.noInfoView.alpha = 1.0
                    
                }
            }
            
        }else if self.type == "Voluntary" {
            
            let queryToReservation = PFQuery(className: "Reservation")
            
            queryToReservation.whereKey("yober", equalTo: user)
            queryToReservation.whereKey("type", equalTo: self.type)
            //queryToReservation.whereKey("active", equalTo: true)
            queryToReservation.includeKey("user")
            
            queryToReservation.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    // The find succeeded.
                    for object in objects {
                        
                        let activityId = object["activityId"] as? String
                        
                        if self.activityIdArray.contains(activityId ?? "") {
                            print("ya lo tiene")
                        }else{
                            self.activityIdArray.append(activityId ?? "")
                            self.reservation.append(object)
                        }
                    }
                }
                if self.reservation.count > 0 {
                    self.listTableVIew.reloadData()
                    self.noInfoView.alpha = 0.0
                }else{
                    self.noInfoView.alpha = 1.0
                }
            }

            
        }else{
            
        }
    }
    
    //MARK: - Actions
    
    @IBAction func backButton(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceMainCell") as! serviceMainCell
        
        let cellReservation = reservation[indexPath.row]
        
        //cell.mainLogo.image = UIImage(named: "")
        
        if let newId = cellReservation["activityId"] as? String{
            let queryToReservation = PFQuery(className: self.type)
        
            queryToReservation.whereKey("objectId", equalTo: newId)
        
            queryToReservation.getFirstObjectInBackground { (object: PFObject!, error: Error?) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let object = object {
                    // The find succeeded.
        
                    if let imageInformation = object["logo"] as? PFFileObject{
        
                        imageInformation.getDataInBackground{
        
                            (imageData: Data?, error: Error?) in
                            if let error = error{
                                print(error.localizedDescription)
                            }else if let imageData = imageData{
        
                                let image = UIImage(data: imageData)
                                cell.mainLogo.image = image
        
                                cell.mainLogo.roundCompleteImageColor()
        
                            }
                        }
                    }else{
        
                        cell.mainLogo.image = nil
        
                    }
        
                }
        
            }
        }
    
        cell.serviceName.text = cellReservation["name"] as? String
        
        if let newDate = cellReservation["date"] as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "es_ES")
            dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
            let labelDate = dateFormatter.string(from: newDate)
            
            cell.serviceDate.text = labelDate
        }else{
            cell.serviceDate.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "agendaCVDetails") as? agendaCVDetails
        
        viewController?.type = self.type
        
        let activityId = self.reservation[indexPath.row]
        let date = activityId["date"] as? Date
        
        if let objectId = activityId["activityId"] as? String {
            
            print("objectId: \(objectId)")
            viewController?.activityId = objectId
            viewController?.schedule = date ?? Date()
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
//    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "serviceYoberDetails") as? serviceYoberDetails
//        viewController?.reservation = reservation[indexPath.row]
//        viewController?.type = self.type
//
//        self.navigationController?.pushViewController(viewController!, animated: true)
            
    }
}
