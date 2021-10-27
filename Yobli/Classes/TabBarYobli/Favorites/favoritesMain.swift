//
//  favoritesMain.swift
//  Yobli
//
//  Created by Brounie on 27/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class favoritesMain: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var favoritesYobersTable: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var titleDataLabel: UILabel!
    
    //MARK: VARs/LETs
    
    //var entry = 0
    var yoberFavorites = [PFObject]()
    
    //MARK: MAIN VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.updateView()
        //entry = 1
        
        favoritesYobersTable.delegate = self
        favoritesYobersTable.dataSource = self
        
        self.noDataView.isHidden = true
        self.titleDataLabel.text = "Aquí verás a tus Yobers favoritos una vez que eligas uno"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
        //if (entry < 1){
            self.updateView()
        //}
        
        //entry = 0
        
        //self.favoritesYobersTable.reloadData()
        
    }
    
    //MARK: FUNC UPDATE VIEW
    
    func updateView(){
        
        let user = PFUser.current()
        self.yoberFavorites = []
        
        if let newYoberArray = user?["favoriteYobers"] as? [PFObject]{
            if newYoberArray.count == 0 {
                self.noDataView.isHidden = false
            }else{
                self.noDataView.isHidden = true
                for object in newYoberArray {
                    if let id = object.objectId {
                        let queryYober : PFQuery = PFUser.query()!
                        queryYober.whereKey("objectId", equalTo: id)
                        queryYober.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
                            if let error = error {
                                // The query failed
                                print(error.localizedDescription)
                            } else if let object = object {
                                // The query succeeded with a matching result
                                self.yoberFavorites.append(object)
                            } else {
                                // The query succeeded but no matching result was found
                            }
                            self.favoritesYobersTable.reloadData()
                        }
                    }
                }
            }
        }else{
            //print("newYoberArray: \(newYoberArray)")
            self.noDataView.isHidden = false
        }
    }
    
    //MARK: GO TO OTHER PROFILE
    
    func goToYoberProfileFromOtherTab(otherUserId: String){
        
        //TAB
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
        
        tabbar.selectedIndex = 2
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            let storyboard2 = UIStoryboard(name: "TabExplore", bundle: nil)
            
            if let viewcontroller = storyboard2.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile {
                
                viewcontroller.yoberId = otherUserId
                
                navigation.pushViewController(viewcontroller, animated: true)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = tabbar
                
            }
            
        }
        
    }
    
}

//MARK: EXTENSION TABLEVIEW

extension favoritesMain: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        yoberFavorites.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = favoritesYobersTable.dequeueReusableCell(withIdentifier: "favoritesMainTableCell") as! favoritesMainTableCell
        
        cell.objects = yoberFavorites[indexPath.item]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let id = yoberFavorites[indexPath.item].objectId else{
            return
        }
        
        self.goToYoberProfileFromOtherTab(otherUserId: id)
        
    }
    
}
