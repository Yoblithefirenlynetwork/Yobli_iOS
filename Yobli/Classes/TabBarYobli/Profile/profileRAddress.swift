//
//  profileRAddress.swift
//  Yobli
//
//  Created by Brounie on 22/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit
import MBProgressHUD

// MARK: STRUCT

struct userAddress : Codable{
    
    var street : String
    var number : String
    var colony : String
    var city : String
    var state : String
    var reference : String
    var selected : Bool
    
}

// MARK: MAIN CLASS

class profileRAddress: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var userStreet: UITextField!
    @IBOutlet weak var userNumberInternal: UITextField!
    @IBOutlet weak var userColony: UITextField!
    @IBOutlet weak var userCity: UITextField!
    @IBOutlet weak var userCityButton: UIButton!
    @IBOutlet weak var userState: UITextField!
    @IBOutlet weak var userStateButton: UIButton!
    @IBOutlet weak var userReference: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: VARs/LETs
    
    var uStreet = ""
    var uNumberI = ""
    var uColony = ""
    var uCity = ""
    var uState = ""
    var uReference = ""
    var buttonSelected = ""
    
    var selectedButton = UIButton()
    
    var cities = [String]()
    var states = [String]()
    
    var stateCities = [PFObject]()
    
    let tableList = UITableView()
    
    let transparentView = UIView()
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.queries()
        
        userStreet.generalBottomLine()
        userNumberInternal.generalBottomLine()
        userColony.generalBottomLine()
        userReference.generalBottomLine()
        
        userStreet.delegate = self
        userNumberInternal.delegate = self
        userColony.delegate = self
        userReference.delegate = self
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        registerButton.roundCustomButton(divider: 8)
        
        self.hideKeyboardWhenTappedAround()
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
    
    @IBAction func saveAddress(_ sender: Any) {
        
        if( self.notEmpty() == true ){
            
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.backgroundView.color = UIColor.gray
            loader.backgroundView.alpha = 0.5
            loader.label.text = "Guardando Información"
            
            let newAddress = userAddress(street: uStreet, number: uNumberI, colony: uColony, city: uCity, state: uState, reference: uReference, selected: false)
            
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(newAddress) {
                
                let user = PFUser.current()!
                
                user.addUniqueObject(encoded, forKey: "locations")
                
                user.saveInBackground {  (success: Bool?, error: Error?) in
                    
                    loader.hide(animated: true)
                    
                    if let error = error {
                        
                        self.sendErrorType(error: error)
                        
                    }else if success != nil{
                            
                        let alert = UIAlertController(title: "ÉXITO", message: "Información de la dirección guardada con éxito", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Continuar", style: .default){ (_) in
                            
                            let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
                            
                            goTo.selectedIndex = 4
                            
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
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "Alguno de los datos está incompleto o vacío", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func displayCities(_ sender: UIButton) {
        
        if(uState != ""){
            
            buttonSelected = "city"
            selectedButton = userCityButton
            
            self.getCities(stateName: uState)
            
            fillTable(frames: userCityButton.frame, number: cities.count)
            
        }
        
    }
    
    @IBAction func displayStates(_ sender: UIButton) {
        
        buttonSelected = "state"
        selectedButton = userStateButton
        
        fillTable(frames: userStateButton.frame, number: states.count)
        
    }
    
    
    // MARK: OTHER FUNCTIONS
    
    func notEmpty() -> Bool{
        
        //&& uNumberI != ""
        
        if( uStreet != "" && uColony != "" && uCity != "" && uState != "" && uReference != ""){
            
            return true
            
        }
        
        return false
        
    }
    
    func getCities(stateName: String){
        
        var x = 0
        
        for state in states{
            
            if(state == stateName){
                
                if let arrayOfCities = stateCities[x]["cities"] as? [String]{
                    
                    cities = arrayOfCities
                    break
                    
                }
                
            }
            
            x = x + 1
            
        }
        
        
    }
    
    
    // MARK: TABLE FUNCTIONS
    
    func queries(){
        
        let queryCities = PFQuery(className: "State")
        
        queryCities.findObjectsInBackground{ (objects: [PFObject]!, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeAndDismiss(error: error)
            } else if let objects = objects {
                // The find succeeded.
                self.stateCities = objects
                
                for object in objects{
                    
                    if let newState = object["name"] as? String{
                        
                        self.states.append(newState)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func fillTable(frames: CGRect, number: Int){
        
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        
        if #available(iOS 13.0, *) {
            transparentView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.02)
        } else {
            // Fallback on earlier versions
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTableView) )
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        
        self.view.addSubview(tableList)
        
        tableList.layer.cornerRadius = 0.5
        
        tableList.reloadData()
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTableView))
        
        //self.view.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0.02
            
            if ( number >= 4){
                
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 200)
                
            }else{
                
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(number * 50))
                
            }
            
            
            
        }, completion: nil)
        
        
    }
    
    @objc func removeTableView(){
        
        let frames = selectedButton.frame
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0
            
            self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
            
            }, completion: nil)
        
    }
    
}

// MARK: TEXTFIELD FUNCTIONS

extension profileRAddress: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField == userStreet){
            
            uStreet = userStreet.text!
            
        }else if (textField == userColony ){
            
            uColony = userColony.text!
            
        }else if (textField ==  userNumberInternal ){
            
            uNumberI = userNumberInternal.text!
            
        }else if (textField == userReference ){
            
            uReference = userReference.text!
            
        }
        
    }
    
}

//MARK: EXTENSION TABLEVIEW

extension profileRAddress: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "state"){
            
            return states.count
            
        }else if(buttonSelected == "city"){
            
            if( uState != ""){
            
                return cities.count
                
            }else{
                
                return 0
                
            }
            
        }else{
            
            return 0
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "city"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = cities[indexPath.item]
            cell.textLabel?.font = userCity.font
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = states[indexPath.item]
            cell.textLabel?.font = userState.font
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "city"){
            
            uCity = cities[indexPath.item]
            userCity.text = cities[indexPath.item]
            removeTableView()
            
        }else if(buttonSelected == "state"){
            
            uState = states[indexPath.item]
            userState.text = states[indexPath.item]
            uCity = ""
            userCity.text = nil
            
            removeTableView()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
