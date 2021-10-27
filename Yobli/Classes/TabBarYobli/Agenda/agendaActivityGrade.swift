//
//  agendaActivityGrade.swift
//  Yobli
//
//  Created by Brounie on 18/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class agendaActivityGrade: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var activityLogo: UIImageView!
    @IBOutlet weak var activityColor: UIView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityTime: UILabel!
    @IBOutlet weak var evaluation: UIButton!
    
    
    //MARK: GRADING OUTLETS
    
    //Grading
    
    @IBOutlet weak var start1: UIButton!
    @IBOutlet weak var start2: UIButton!
    @IBOutlet weak var start3: UIButton!
    @IBOutlet weak var start4: UIButton!
    @IBOutlet weak var start5: UIButton!
    
    //MARK: VARs/LETs
    
    var grade = 0.0
    var getReservation = PFObject(className: "Reservation")
    var yoberGrade = PFObject(className: "Grade")
    
    //MARK: MAIN FUNC VIEWDIDLOAD
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        self.showHUD(progressLabel: "Cargando...")
        
        evaluation.roundCustomButton(divider: 8)
        
        self.updateView()
        
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTION GRADE
    
    @IBAction func startGrade1(_ sender: UIButton) {
        
        start1.setImage(UIImage(named: "starSelected"), for: .normal)
        start2.setImage(UIImage(named: "starUnSelected"), for: .normal)
        start3.setImage(UIImage(named: "starUnSelected"), for: .normal)
        start4.setImage(UIImage(named: "starUnSelected"), for: .normal)
        start5.setImage(UIImage(named: "starUnSelected"), for: .normal)
        grade = 1.0
        
    }
    
    @IBAction func startGrade2(_ sender: UIButton) {
        
        start1.setImage(UIImage(named: "starSelected"), for: .normal)
        start2.setImage(UIImage(named: "starSelected"), for: .normal)
        start3.setImage(UIImage(named: "starUnSelected"), for: .normal)
        start4.setImage(UIImage(named: "starUnSelected"), for: .normal)
        start5.setImage(UIImage(named: "starUnSelected"), for: .normal)
        grade = 2.0
        
    }
    
    @IBAction func startGrade3(_ sender: UIButton) {
        
        start1.setImage(UIImage(named: "starSelected"), for: .normal)
        start2.setImage(UIImage(named: "starSelected"), for: .normal)
        start3.setImage(UIImage(named: "starSelected"), for: .normal)
        start4.setImage(UIImage(named: "starUnSelected"), for: .normal)
        start5.setImage(UIImage(named: "starUnSelected"), for: .normal)
        grade = 3.0
        
    }
    
    @IBAction func startGrade4(_ sender: UIButton) {
        
        start1.setImage(UIImage(named: "starSelected"), for: .normal)
        start2.setImage(UIImage(named: "starSelected"), for: .normal)
        start3.setImage(UIImage(named: "starSelected"), for: .normal)
        start4.setImage(UIImage(named: "starSelected"), for: .normal)
        start5.setImage(UIImage(named: "starUnSelected"), for: .normal)
        grade = 4.0
        
    }
    
    @IBAction func startGrade5(_ sender: UIButton) {
        
        start1.setImage(UIImage(named: "starSelected"), for: .normal)
        start2.setImage(UIImage(named: "starSelected"), for: .normal)
        start3.setImage(UIImage(named: "starSelected"), for: .normal)
        start4.setImage(UIImage(named: "starSelected"), for: .normal)
        start5.setImage(UIImage(named: "starSelected"), for: .normal)
        grade = 5.0
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: BUTTON FUNCTION SAVE
    
    @IBAction func saveEvaluation(_ sender: UIButton) {
        
        sendGrade()
        
    }
    
    //MARK: RETRIEVE FUNC
    
    func updateView(){
        
        if let newDate = getReservation["date"] as? Date{
            
            let dateFormatter = DateFormatter()
            
            
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            
            let labelDate = dateFormatter.string(from: newDate)
            
            self.activityTime.text = labelDate
            
        }else{
            
            self.activityTime.text = nil
            
        }
        
        if let newName  = getReservation["name"] as? String{
            self.activityName.text = newName
        }else{
            self.activityName.text = nil
        }
        
        if let newType = getReservation["type"] as? String{
            
            guard let activityId = getReservation["activityId"] as? String else{
                return
            }
            
            if(newType == "Course"){
                
                self.getActivity(activityId: activityId, type: newType)
                
                activityColor.backgroundColor = UIColor.init(red: 255/255, green: 0, blue: 149/255, alpha: 1)
                activityColor.roundCompleteView()
                
            }else if(newType == "Voluntary"){
                
                self.getActivity(activityId: activityId, type: newType)
                
                activityColor.backgroundColor = UIColor.init(red: 255/255, green: 223/255, blue: 0, alpha: 1)
                activityColor.roundCompleteView()
                
            }else{
                
                self.getActivity(activityId: activityId, type: newType)
                
                activityColor.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
                activityColor.roundCompleteView()
                
            }
            
        }
        
        if let yober = getReservation["yober"] as? PFObject{
            
            getGradeOfY(yober: yober)
            
        }
        
    }
    
    func getGradeOfY(yober: PFObject){
        
        let queryGrade = PFQuery(className: "Grade")
        
        queryGrade.whereKey("yober", equalTo: yober)
        
        queryGrade.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            
            if let error = error {
                self.dismissHUD(isAnimated: true)
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = object {
                // The find succeeded.
                self.dismissHUD(isAnimated: true)
                
                self.yoberGrade = object
                
            }
            
        }
        
    }
    
    func getActivity(activityId: String, type: String){
        
        let queryActivity = PFQuery(className: type)
        
        queryActivity.whereKey("objectId", equalTo:activityId)
        
        queryActivity.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
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
                            
                            self.activityLogo.image = image
                            
                            self.activityLogo.roundCompleteImage()
                            
                        }
                        
                    }
                
                }else{
                    
                    self.activityLogo.image = nil
                    
                    self.activityLogo.roundCompleteImage()
                    
                }
            }
            
        }
        
    }
    
    //MARK: SAVE FUNC
    
    func sendGrade(){
        
        self.showHUD(progressLabel: "Enviando calificación")
        
        if(grade == 0){
            
            errorSituation(error: "No se ha dado una calificación a la actividad seleccionada")
            
        }else{
            
            let yober = self.getReservation["user"] as? PFObject
            let yoberId = yober?.objectId ?? ""
            
            let yoberGradeId = PFQuery(className: "Grade")
            yoberGradeId.whereKey("yober", contains: yoberId)
            print("yoberId: \(yoberId)")
            yoberGradeId.getFirstObjectInBackground { (yober, error) in
                
                if let error = error{
                    print("error: \(error)")
                }else if let yober = yober {
                    
                    
                    guard let originalGrade = yober["grade"] as? Double, let originalNumOfGraders = yober["numberOfGrades"] as? Double else{
                    
                        self.errorSituation(error: "Algo ha fallado")
                        return
                    
                    }
                    
                    let trueTotal = originalGrade * originalNumOfGraders
                    
                    let newTotal = trueTotal + self.grade
                    let newNumberOfGraders = originalNumOfGraders + 1
                    
                    let newGrade = newTotal/newNumberOfGraders
                    
                    yober["numberOfGrades"] = newNumberOfGraders
                    yober["grade"] = newGrade
                    
                    
                    self.getReservation["grade"] = true
                    self.getReservation["active"] = false
                    
                    self.getReservation.saveInBackground { (success: Bool?, error: Error?) in
                        if let error = error {
                            self.dismissHUD(isAnimated: true)
                            self.errorSituation(error: error.localizedDescription)
                        } else if success != nil {
                            self.dismissHUD(isAnimated: true)
                            self.goTo()
                        } else {
                            self.dismissHUD(isAnimated: true)
                        }
                    }
                    yober.saveInBackground()
                }
            }
//            yoberGrade.fetchInBackground { (result, error) in
//
//                if let error = error{
//
//                    self.dismissHUD(isAnimated: true)
//
//                    self.sendErrorType(error: error)
//
//                }else if let result = result{
//
//                    self.yoberGrade = result
//
//                    guard let originalGrade = self.yoberGrade["grade"] as? Double, let originalNumOfGraders = self.yoberGrade["numberOfGrades"] as? Double else{
//
//                        self.errorSituation(error: "Algo ha fallado")
//
//                        return
//
//                    }
//
//                    let trueTotal = originalGrade * originalNumOfGraders
//
//                    let newTotal = trueTotal + self.grade
//                    let newNumberOfGraders = originalNumOfGraders + 1
//
//                    let newGrade = newTotal/newNumberOfGraders
//
//                    self.yoberGrade["numberOfGrades"] = newNumberOfGraders
//                    self.yoberGrade["grade"] = newGrade
//
//                    self.yoberGrade.saveInBackground { (success: Bool?, error: Error?) in
//
//                        if let error = error {
//
//                            self.dismissHUD(isAnimated: true)
//
//                            self.errorSituation(error: error.localizedDescription)
//
//                        } else if success != nil {
//
//                            self.getReservation["grade"] = true
//
//                            self.getReservation["active"] = false
//
//                            self.getReservation.saveInBackground { (success: Bool?, error: Error?) in
//
//                                if let error = error {
//
//                                    self.dismissHUD(isAnimated: true)
//
//                                    self.errorSituation(error: error.localizedDescription)
//
//                                } else if success != nil {
//
//                                    self.dismissHUD(isAnimated: true)
//
//                                    self.goTo()
//
//                                } else {
//
//                                    self.dismissHUD(isAnimated: true)
//
//                                }
//
//                            }
//
//                        } else{
//
//                            self.dismissHUD(isAnimated: true)
//
//                        }
//
//                    }
//
//                }
//           }
        }
    }
    
    //MARK: ERROR FUNC
    
    func errorSituation(error: String){
        
        self.dismissHUD(isAnimated: true)
        
        let alert = UIAlertController(title: "ERROR", message: error, preferredStyle: .alert)
                    
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: goTo FUNC
    
    func goTo(){
        
        let alert = UIAlertController(title: "ÉXITO", message: "Calificado", preferredStyle: .alert)
        
        //This action is to goBack to the agenda
        
        let action = UIAlertAction(title: "Continuar", style: .default){ (_) in
            
            let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
            
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

//MARK: LOADING EXTENSION

extension agendaActivityGrade{
    
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
