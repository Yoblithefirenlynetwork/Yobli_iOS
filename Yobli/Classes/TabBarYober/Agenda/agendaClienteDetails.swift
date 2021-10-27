//
//  agendaClienteDetails.swift
//  Yobli
//
//  Created by Brounie on 07/01/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class agendaClienteDetails: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var subscriberPhoto: UIImageView!
    @IBOutlet weak var subscriberName: UILabel!
    @IBOutlet weak var subscriberCreationDate: UILabel!
    @IBOutlet weak var subscriberDescription: UITextView!
    @IBOutlet weak var subscriberDescriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var subscriberPhone: UILabel!
    @IBOutlet weak var subscriberResume: UITableView!
    
    //MARK: VARs/LETs
    
    var subscriberId = ""
    var contratedServices = 0
    var contratedCourses = 0
    var contratedVoluntaries = 0
    var registerDirection = false
    var registerPhone = false
    var registerId = false
    
    //MARK: VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        self.subscriberResume.delegate = self
        self.subscriberResume.dataSource = self
        
        self.subscriberPhoto.roundCompleteImageColor()
        
        self.dismissWithSwipe()
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func reportUser(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "agendaClientReport") as? agendaClientReport
        
        viewController?.reportedId = subscriberId
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    //MARK: FUNC UPDATE
    
    func updateView(){
        
        if subscriberId != ""{
            
            queryDetails(id: subscriberId)
            
        }
        
    }
    
    func queryDetails(id: String){
        
        let queryToUser : PFQuery = PFUser.query()!
        
        queryToUser.whereKey("objectId", equalTo: id)
        
        queryToUser.getFirstObjectInBackground { (object, error) in
            
            if let error = error {
                
                self.sendErrorTypeAndDismiss(error: error)
                
            }else if let object = object{
                
                if let imageInformation = object["userPhoto"] as? PFFileObject{
                    
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            self.subscriberPhoto.image = image
                        }
                        
                    }
                    
                }
                
                if let newName = object["name"] as? String{
                    self.subscriberName.text = newName
                }else{
                    self.subscriberName.text = nil
                }
                
                if let newDate = object.createdAt{
                    
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.locale = Locale(identifier: "es_MX")
                    dateFormatter.dateFormat = "EEEE dd, MMMM yyyy, HH:mm"
                    dateFormatter.amSymbol = "AM"
                    dateFormatter.pmSymbol = "PM"
                    
                    let labelDate = dateFormatter.string(from: newDate)
                    
                    self.subscriberCreationDate.text = "Miembro desde: " + labelDate
                    
                }else{
                    
                    self.subscriberCreationDate.text = nil
                    
                }
                
                if let newDescription = object["userDescription"] as? String{
                    
                    self.subscriberDescription.text = newDescription
                    
                    let height = self.subscriberDescription.contentSize.height
                    
                    self.subscriberDescriptionHeight.constant = height
                    
                    self.mainView.layoutIfNeeded()
                    
                }else{
                    self.subscriberDescription.text = nil
                    
                    self.subscriberDescriptionHeight.constant = CGFloat(0)
                    
                    self.mainView.layoutIfNeeded()
                    
                }
                
                if let newCode = object["userPhoneCode"] as? String{
                    
                    if let newPhone = object["userPhoneNumber"] as? String{
                        
                        if(newPhone != "" && newCode != ""){
                            
                            self.subscriberPhone.text = newCode + newPhone
                            
                        }else{
                            
                            self.subscriberPhone.text = nil
                            
                            
                        }
                        
                        
                    }else{
                        self.subscriberPhone.text = nil
                    }
                    
                }else{
                    self.subscriberPhone.text = nil
                }
                
                if let directions = object["locations"] as? [Data]{
                    
                    if ( directions.count > 0 ){
                        
                        self.registerDirection = true
                        
                    }
                    
                }
                
                if let newPhoneCode = object["userPhoneCode"] as? String, newPhoneCode != ""{
                    
                    if let newPhoneNumber = object["userPhoneNumber"] as? String, newPhoneNumber != ""{
                        
                        self.registerPhone = true
                        
                    }
                    
                }
                
                if let imageInformation = object["userIdentification"] as? PFFileObject{
                    
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            self.registerId = true
                            
                        }
                        
                    }
                    
                }
                
                self.subscriberResume.reloadData()
                
                self.queryData(user: object, type: "Course")
                self.queryData(user: object, type: "Voluntary")
                self.queryData(user: object, type: "Service")
            
                
            }
            
        }
        
    }
    
    func queryData(user: PFObject, type: String){
        
        let queryReservations = PFQuery(className: "Reservation")
        queryReservations.whereKey("user", equalTo: user)
        queryReservations.whereKey("type", equalTo: type)
        
        queryReservations.countObjectsInBackground { (result, error) in
            if error == nil{
                
                switch type {
                case "Course":
                    self.contratedCourses = Int(result)
                    self.subscriberResume.reloadData()
                    break
                case "Service":
                    self.contratedServices = Int(result)
                    self.subscriberResume.reloadData()
                    break
                case "Voluntary":
                    self.contratedVoluntaries = Int(result)
                    self.subscriberResume.reloadData()
                    break
                default:
                    break
                }
                
            }
        }
        
        
    }
    
    //MARK: FUNC REPORT
    
}

//MARK: EXTENSION TABLEVIEW

extension agendaClienteDetails: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if( indexPath.row < 3 ){
            
            let cell = subscriberResume.dequeueReusableCell(withIdentifier: "agendaSubscriberResume1") as! agendaSubscriberResume1
            
            switch indexPath.row {
            case 1:
                cell.activityType.text = "Cursos Inscritos"
                cell.activityNumber.text = "\(contratedCourses)"
                break
            case 2:
                cell.activityType.text = "Agente de Cambio"
                cell.activityNumber.text = "\(contratedVoluntaries)"
                break
            default:
                cell.activityType.text = "Servicios Contratados"
                cell.activityNumber.text = "\(contratedServices)"
                break
            }
            
            return cell
            
        }else{
            
            let cell = subscriberResume.dequeueReusableCell(withIdentifier: "agendaSubscriberResume2") as! agendaSubscriberResume2
            
            switch indexPath.row {
            case 3:
                cell.dataType.text = "Dirección"
                if( registerDirection != false ){
                    cell.dataResult.image = UIImage(named: "checkTrue")
                }else{
                    cell.dataResult.image = UIImage(named: "checkFalse")
                }
                break
            case 4:
                cell.dataType.text = "Teléfono"
                if( registerPhone != false ){
                    cell.dataResult.image = UIImage(named: "checkTrue")
                }else{
                    cell.dataResult.image = UIImage(named: "checkFalse")
                }
                break
            default:
                cell.dataType.text = "Identificación"
                if( registerId != false ){
                    cell.dataResult.image = UIImage(named: "checkTrue")
                }else{
                    cell.dataResult.image = UIImage(named: "checkFalse")
                }
                break
            }
            
            return cell
            
        }
        
    }
    
}
