//
//  exploreVoluntaryInscription.swift
//  Yobli
//
//  Created by Brounie on 31/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class exploreVoluntaryInscription: UIViewController{
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var voluntaryDate: UILabel!
    
    @IBOutlet weak var voluntaryDetails: UITableView!
    
    
    var voluntary = PFObject(className: "Voluntary")
    var registrations = [PFObject]()
    var reservationDone = false
    var pointerKey = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        guard let user = PFUser.current() else {
            self.sendAlert()
            return
        }
        
        guard let idVoluntary = voluntary.objectId, let yober = voluntary["yober"] as? PFObject else{
            print("Something is wrong")
            return
        }
        
        self.compareRegistrations(keyFromActivity: idVoluntary, user: user, yober: yober)
        
        voluntaryDetails.delegate = self
        voluntaryDetails.dataSource = self
        
        yoberPhoto.roundCompleteImageColor()
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func inscriptionConfirm(_ sender: Any) {
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            return
            
        }
        
        guard let actualId = user.objectId, let yober = voluntary["yober"] as? PFObject, let yoberId = yober.objectId else{
            
            self.customError(description: "Algo salió mal al momento de obtener su o la id del creador")
            return
            
        }
        
        if( actualId == yoberId ){
            
            self.customError(description: "El creador y el usuario son el mismo, no puede unirse")
            
        }else{
        
            self.voluntary.fetchInBackground { (result, error) in
                
                if let error = error{
                    
                    self.sendErrorType(error: error)
                    
                }else if let result = result{
                    
                    self.voluntary = result
                    
                    guard let inscriptionsDone = self.voluntary["inscriptions"] as? Int, let numberLimit = self.voluntary["places"] as? Int else{
                        
                        self.customError(description: "El voluntariado tiene errores, contactar al creador")
                        
                        return
                        
                    }
                    
                    if(inscriptionsDone < numberLimit){
                        
                        if( self.reservationDone == false ){
                            
                            self.showHUD(progressLabel: "Reservation Done")
                            
                            let newRegistration = PFObject(className: "Reservation")
                                        
                            guard let yober = self.voluntary["yober"] as? PFObject,
                                  let yoberId = yober.objectId,
                                  let newName = self.voluntary["name"] as? String,
                                  let newTime = self.voluntary["duration"] as? String,
                                  let newDate = self.voluntary["date"] as? Date,
                                  let newLocation = self.voluntary["location"] as? String,
                                  let voluntaryId = self.voluntary.objectId else{
                                
                                self.dismissHUD(isAnimated: true)
                                
                                self.customError(description: "Esto no debería pasar, confirmar con el creador, faltan datos")
                                return
                                
                            }
                            
                            newRegistration["yober"] = yober
                            newRegistration["name"] = newName
                            newRegistration["duration"] = newTime
                            newRegistration["date"] = newDate
                            newRegistration["location"] = newLocation
                            
                            newRegistration["user"] = user
                            newRegistration["type"] = "Voluntary"
                            newRegistration["activityId"] = self.voluntary.objectId
                            newRegistration["active"] = true
                            newRegistration["grade"] = false
                                        
                            if let newInscriptions = self.voluntary["inscriptions"] as? Int{
                                            
                                self.voluntary["inscriptions"] = newInscriptions + 1
                                            
                            }else{
                                
                                self.dismissHUD(isAnimated: true)
                                self.customError(description: "Esto no debería pasar, contactar al usuario")
                                
                            }
                            
                            
                            
                            newRegistration.saveInBackground { (success: Bool?, error: Error?) in
                                
                                if let error = error {
                                    // The query failed
                                    self.dismissHUD(isAnimated: true)
                                    
                                    self.sendErrorType(error: error)
                                } else if success != nil {
                                    
                                    self.dismissHUD(isAnimated: true)
                                    
                                    // The query succeeded with a matching result
                                    if let newId = newRegistration.objectId{
                                        
                                        let pointer = PFObject(withoutDataWithClassName: "Reservation", objectId: newId)
                                        
                                        guard let userSaving = PFUser.current() else{
                                            
                                            self.sendAlert()
                                            return
                                            
                                        }
                                        
                                        userSaving.addUniqueObject(pointer, forKey:"registerEvents")
                                        
                                        userSaving.saveInBackground()
                                        
                                        self.voluntary.saveInBackground()
                                        
                                        NotificationHandler.createAlertForReservation(receiver: yober, receiverId: yoberId, notificationType: "Reservation", activityId: voluntaryId, activityType: "Voluntary", activityName: newName, pointerToReservation: newRegistration)
                                        
                                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "exploreRegistrationSuccess") as? exploreRegistrationSuccess
                                        
                                        viewController?.typeOfActivity = "Voluntary"
                                        viewController?.reservation = newRegistration

                                        self.navigationController?.pushViewController(viewController!, animated: true)
                                        
                                    }else{
                                        
                                        self.dismissHUD(isAnimated: true)
                                        self.customError(description: "Algo salió mal durante el guardado de la reserva")
                                        
                                    }
                                    
                                }else{
                                    
                                    self.dismissHUD(isAnimated: true)
                                    self.customError(description: "Algo salió mal creando la reserva")
                                    
                                }
                                
                            }
                            
                        }else{
                            
                            self.eventAllReadyRegister()

                        }
                        
                    }else{
                        
                        self.eventFull()

                    }
                    
                }
            
            }
        
        }
        
                    
    }
    
    //MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        if let newDate = voluntary["date"] as? Date{
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            
            let labelDate = dateFormatter.string(from: newDate)
            
            self.voluntaryDate.text = labelDate
            
        }
        
        
        if let yober = voluntary["yober"] as? PFObject{
            self.getUser(object: yober)
        }else{
            print("This should not happen, there is always a userId when a new voluntary is created")
        }
        
    }
    
    func compareRegistrations(keyFromActivity: String, user: PFObject, yober: PFObject){
        
        let queryReservation = PFQuery(className: "Reservation")
        
        queryReservation.whereKey("activityId", equalTo: keyFromActivity)
        queryReservation.whereKey("type", contains: "Voluntary")
        queryReservation.whereKey("yober", equalTo: yober)
        queryReservation.whereKey("user", equalTo: user)
        queryReservation.whereKey("active", equalTo: true)
        
        queryReservation.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            
            if let error = error {
                // The query failed
                print(error.localizedDescription)
            } else if object != nil {
                // The query succeeded with a matching result
                self.reservationDone = true
                
            }
            
        }
        
    }
    
    func getUser(object: PFObject){
        
        if let imageInformation = object["userPhoto"] as? PFFileObject{
                
            imageInformation.getDataInBackground{
                (imageData: Data?, error: Error?) in
                
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                                
                    let image = UIImage(data: imageData)
                                
                    self.yoberPhoto.image = image
                        
                }
                
            }
                
        }
            
        if let newName = object["name"] as? String {
            self.yoberName.text = newName
        }else{
            self.yoberName.text = nil
        }
            
        guard let id = object.objectId else {
            print("Id of yober doesnt appear")
            return
        }
                
        self.yoberGrade.gradeResults(id: id)
        
    }
    
    //MARK: ERROR FUNCTIONS
    
    func eventFull(){
        
        let alert = UIAlertController(title: "ERROR", message: "Este voluntariado ya no tiene más lugares", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
    func eventAllReadyRegister(){
        
        let alert = UIAlertController(title: "ERROR", message: "Ya se registró a este Voluntariado", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
}

//MARK: TABLE EXTENSION

extension exploreVoluntaryInscription: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = voluntaryDetails.dequeueReusableCell(withIdentifier: "exploreInscriptionCell2", for: indexPath) as! exploreInscriptionCell
        
        switch indexPath.row{
                
            case 1:
                
                if let newTime = voluntary["duration"] as? String{
                    cell.information.text = newTime
                    cell.icon.image = UIImage(named: "timeIcon")
                }else{
                    cell.information.text = nil
                }
                
            case 2:
                
                if let newLocation = voluntary["location"] as? String{
                    cell.information.text = newLocation
                    cell.icon.image = UIImage(named: "zoneIcon")
                }else{
                    cell.information.text = nil
                }
                
                
            default:
                
                if let newName = voluntary["name"] as? String{
                    cell.information.text = newName
                    cell.icon.image = UIImage(named: "activityIcon")
                }else{
                    cell.information.text = nil
                }
                
        }
            
        
        return cell
    }
    
    
}

//MARK: SHOW HUD EXTENSION

extension exploreVoluntaryInscription{
    
    func showHUD(progressLabel:String){
        DispatchQueue.main.async{
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.backgroundView.color = UIColor.gray
            loader.backgroundView.alpha = 0.5
            loader.label.text = progressLabel
        }
    }

    func dismissHUD(isAnimated:Bool) {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view, animated: isAnimated)
        }
    }
    
}
