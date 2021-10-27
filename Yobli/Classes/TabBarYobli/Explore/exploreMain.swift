//
//  exploreMain.swift
//  Yobli
//
//  Created by Humberto on 7/23/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/*
 class exploreMain
 
 
 
 
 */

import Foundation
import UIKit
import Parse

class exploreMain: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var exploreCollectionView: UICollectionView!
    
    @IBOutlet weak var forMeCollectionView: UICollectionView!
    
    @IBOutlet weak var yoberCollectionView: UICollectionView!
    
    //MARK: VARs/LETs
    
    var yoberBar = [PFObject]()
    var exploreBar = [PFObject]()
    var forMeBar = [PFObject]()
    
    //MARK: MAIN FUNCTIONS
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.queries()
        
        //Query to get the Categorys on the Database
        exploreCollectionView.delegate = self
        exploreCollectionView.dataSource = self
        forMeCollectionView.delegate = self
        forMeCollectionView.dataSource = self
        yoberCollectionView.delegate = self
        yoberCollectionView.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.queries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goToSearch(_ sender: UIButton) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "searchController") as? searchController
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    
    //MARK: OTHER FUNCTIONS
    
    func queries(){
        
        //Queries to get from the Database
        
        let queryExplore = PFQuery(className:"Category")
        queryExplore.order(byAscending: "name")
        queryExplore.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.exploreBar = object
            }
            
            self.exploreCollectionView.reloadData()
            
        }
        
        ///Query to get the Categories on the Database
        
        let queryForMe = PFQuery(className:"Classification")
        
        queryForMe.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.forMeBar = object
                
            }
            
            self.forMeCollectionView.reloadData()
            
        }
        
        
        //Query to get the Users that are Yobers
        
        let queryYoberGraded = PFQuery(className: "Grade")
        
        queryYoberGraded.whereKey("grade", greaterThanOrEqualTo: 4)
        
        queryYoberGraded.addDescendingOrder("numberOfGrades")
        
        queryYoberGraded.includeKey("yober")
        
        queryYoberGraded.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let objects = objects {
                // The find succeeded.
                if(objects.count > 0){
                    
                    self.yoberBar = supportView.orderGradeClass(arrayGrade: objects)
                    
                }
                
            }
            
            self.yoberCollectionView.reloadData()
            
        }
        
    }
    
}

//MARK: EXTENSION COLLECTION VIEW
 
extension exploreMain: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == yoberCollectionView){
            
            return yoberBar.count
            
        }else if(collectionView == forMeCollectionView){
            
            return forMeBar.count
            
            
        }
        
        return exploreBar.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == yoberCollectionView){
            
            let cell2 = yoberCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreMainYoberCell", for: indexPath) as! exploreMainYoberCell
            
            cell2.objects = yoberBar[indexPath.item]
            
            return cell2
            
        }else if(collectionView == forMeCollectionView){
            
            let cell3 = forMeCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreMainForMeCell", for: indexPath) as! exploreMainForMeCell
            
            cell3.objects = forMeBar[indexPath.item]
            
            return cell3
            
        }
        
        let cell = exploreCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreMainCell", for: indexPath) as! exploreMainCell
        
        cell.objects = exploreBar[indexPath.item]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView == exploreCollectionView){
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCategoryMain") as? exploreCategoryMain
            
            viewController?.objects = exploreBar[indexPath.item]
            
            self.navigationController?.pushViewController(viewController!, animated: true)

            
        }else if(collectionView == forMeCollectionView){
            
            if let keyOfForMe : String = forMeBar[indexPath.item]["name"] as? String{
                
                if(keyOfForMe == "CURSOS"){
                    
//                    let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCoursesList") as? exploreCoursesList
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCoursesListDetails") as? exploreCoursesListDetails
                    
                    
                    
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }else if(keyOfForMe == "BLOG"){
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreBlogList") as? exploreBlogList
                    
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }else if(keyOfForMe == "VOLUNTARIOS"){
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreVoluntaryList") as? exploreVoluntaryList
                    
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }
                
            }else{
                
                print("It didnt work")
                
            }
            
        }else if(collectionView == yoberCollectionView){
            
            if let yober = yoberBar[indexPath.item]["yober"] as? PFObject{
                
                guard let id = yober.objectId else{
                    
                    print("Impossible")
                    
                    return
                    
                }
            
                let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile
            
                viewController?.yoberId = id
            
                self.navigationController?.pushViewController(viewController!, animated: true)
            
            }else{
            
                print("It didnt work")
            
            }
            
        }
        
    }
    
}
