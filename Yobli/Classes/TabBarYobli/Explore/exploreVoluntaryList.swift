//
//  exploreVoluntaryList.swift
//  Yobli
//
//  Created by Humberto on 8/4/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class CellForTable: UITableViewCell{
    
}

class exploreVoluntaryList: UIViewController{
    
    @IBOutlet weak var voluntaryCollectionView: UICollectionView!
    
    @IBOutlet weak var voluntaryLogo: UIImageView!
    
    @IBOutlet var causesButton: UIButton!
    
    @IBOutlet weak var statesButton: UIButton!
    
    @IBOutlet weak var causeSubView: UIView!
    
    @IBOutlet weak var stateSubView: UIView!
    
    @IBOutlet weak var causeLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var titleDataLabel: UILabel!
    
    
    var voluntaryListArray = [PFObject]()
    var voluntaryStateArray = [PFObject]()
    var voluntaryCausesArray = [PFObject]()
    let tableList = UITableView()
    var selectedButton = UIButton()
    var buttonSelected = ""
    var cause = PFObject(className: "Cause")
    var state = ""
    let transparentView = UIView()
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.queries()
        self.queries2()
        self.queries3()
        
        statesButton.roundCustomButton(divider: 16)
        
        stateSubView.roundCustomView(divider: 16)
        
        causesButton.roundCustomButton(divider: 16)
        
        causeSubView.roundCustomView(divider: 16)
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        voluntaryCollectionView.delegate = self
        voluntaryCollectionView.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.noDataView.isHidden = true
        self.titleDataLabel.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goToSearch(_ sender: UIButton) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "searchController") as? searchController
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func displayCausesList(_ sender: Any) {
        
        buttonSelected = "causes"
        selectedButton = causesButton
        
        fillTable(frames: causesButton.frame, number: voluntaryCausesArray.count)
        
    }
    
    @IBAction func displayStatesList(_ sender: Any) {
        
        buttonSelected = "states"
        selectedButton = statesButton
        
        fillTable(frames: statesButton.frame, number: voluntaryStateArray.count)
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    func queries(){
        
        //Queries to get from the Database
        let currentDate = Date()
        let user = PFUser.current()
        let blockYobers = user?["blockYobers"] as? [String] ?? [""]
        
        blockYobers.forEach {item in
            
            let queryVoluntary = PFQuery(className:"Voluntary")
            queryVoluntary.whereKey("yober", notEqualTo: item)
            queryVoluntary.whereKey("active", equalTo: true)
            queryVoluntary.whereKey("date", greaterThan: currentDate)
            queryVoluntary.addDescendingOrder("view")
            
            queryVoluntary.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    // The find succeeded.
                    if objects.count == 0 {
                        self.noDataView.isHidden = false
                        self.titleDataLabel.text = "No hay voluntarios disponibles por el momento"
                    }else{
                        // The find succeeded.
                        self.voluntaryListArray = objects
                        self.noDataView.isHidden = true
                        self.titleDataLabel.text = ""
                    }
                }
                self.voluntaryCollectionView.reloadData()
            }
        }
    }
    
    func queryByCause(){
        
        self.noDataView.isHidden = true
        self.titleDataLabel.text = ""
        
        //Queries to get from the Database
        let currentDate = Date()
        
        let user = PFUser.current()
        let blockYobers = user?["blockYobers"] as? [String] ?? [""]
        
        blockYobers.forEach {item in
            let queryVoluntary = PFQuery(className:"Voluntary")
            
            if(state != ""){
                queryVoluntary.whereKey("state", equalTo: state)
            }
            
            queryVoluntary.whereKey("yober", notEqualTo: item)
            queryVoluntary.whereKey("cause", equalTo: cause)
            queryVoluntary.whereKey("active", equalTo: true)
            queryVoluntary.whereKey("date", greaterThan: currentDate)
            queryVoluntary.addDescendingOrder("view")
            
            queryVoluntary.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    // The find succeeded.
                    if objects.count == 0 {
                        self.noDataView.isHidden = false
                        self.titleDataLabel.text = "No hay voluntarios disponibles por el momento"
                    }else{
                        // The find succeeded.
                        self.voluntaryListArray = objects
                        self.noDataView.isHidden = true
                        self.titleDataLabel.text = ""
                    }
                }
                self.voluntaryCollectionView.reloadData()
                
            }
        }
    }
    
    func queryByState(){
        
        self.noDataView.isHidden = true
        self.titleDataLabel.text = ""
        
        //Queries to get from the Database
        let currentDate = Date()
        
        let user = PFUser.current()
        let blockYobers = user?["blockYobers"] as? [String] ?? [""]
        
        blockYobers.forEach {item in
            let queryVoluntary = PFQuery(className:"Voluntary")
            
            if(cause.objectId != nil){
                queryVoluntary.whereKey("cause", equalTo: cause)
            }
            
            queryVoluntary.whereKey("yober", notEqualTo: item)
            queryVoluntary.whereKey("state", contains: state)
            queryVoluntary.whereKey("active", equalTo: true)
            queryVoluntary.whereKey("date", greaterThan: currentDate)
            queryVoluntary.addDescendingOrder("view")
            
            queryVoluntary.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    // The find succeeded.
                    if objects.count == 0 {
                        self.noDataView.isHidden = false
                        self.titleDataLabel.text = "No hay voluntarios disponibles por el momento"
                    }else{
                        // The find succeeded.
                        self.voluntaryListArray = objects
                        self.noDataView.isHidden = true
                        self.titleDataLabel.text = ""
                    }
                }
                
                self.voluntaryCollectionView.reloadData()
            }
        }
    }
    
    // MARK: TABLE FUNCTIONS
    
    func queries2(){
        
        let queryCauses = PFQuery(className: "Cause")
        
        queryCauses.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = objects {
                // The find succeeded.
                self.voluntaryCausesArray = object
            }
            
        }
        
    }
    
    func queries3(){
        
        let queryCities = PFQuery(className: "State")
        
        queryCities.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = objects {
                // The find succeeded.
                self.voluntaryStateArray = object
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
            transparentView.backgroundColor = UIColor.white.withAlphaComponent(0.02)
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

// MARK: EXTENSION TABLEVIEW

extension exploreVoluntaryList: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "causes"){
            
            return voluntaryCausesArray.count
            
        }else{
            
            return voluntaryStateArray.count
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "causes"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = voluntaryCausesArray[indexPath.item]["name"] as? String
            cell.textLabel?.font = causeLabel.font
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = voluntaryStateArray[indexPath.item]["name"] as? String
            cell.textLabel?.font = stateLabel.font
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "causes"){
            
            if let newNameCauses : String = voluntaryCausesArray[indexPath.item]["name"] as? String{
                
                causeLabel.text = newNameCauses
                cause = voluntaryCausesArray[indexPath.item]
                queryByCause()
                removeTableView()
                
            }else{
                
                print("It didnt work")
                
            }
            
        }else{
            
            if let newNameStates : String = voluntaryStateArray[indexPath.item]["name"] as? String{
                
                state = newNameStates
                stateLabel.text = newNameStates
                queryByState()
                removeTableView()
                
            }else{
                
                print("It didnt work")
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: EXTENSION COLLECTIONVIEW

extension exploreVoluntaryList: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voluntaryListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = voluntaryCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreVoluntaryListCell", for: indexPath) as! exploreVoluntaryListCell
        
        cell.objects = voluntaryListArray[indexPath.item]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreVoluntary") as? exploreVoluntary
        
        guard let id = voluntaryListArray[indexPath.item].objectId else{
            return
        }
        
        let voluntary = self.voluntaryListArray[indexPath.item]
        let yober = voluntary["yober"] as? PFObject
        let yoberId = yober?.objectId
        
        viewController?.yoberObjectId = yoberId ?? ""
        viewController?.voluntaryId = id
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthSize = collectionView.frame.width/2 - 20
        let heightSize = widthSize/2 + 15
        
        return CGSize(width: widthSize, height: heightSize)
        
    }
    
}
