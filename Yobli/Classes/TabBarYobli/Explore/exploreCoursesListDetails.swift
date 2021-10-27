//
//  exploreCoursesListDetails.swift
//  Yobli
//
//  Created by Humberto on 8/3/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/* MARK: MAIN INFORMATION
 
 Class exploreCourseListDetails
 
 This class will display two collectionViews, one with the type of courses, and the other all the courses of a certain type that are active.
 
 Variables:
 
 Outlet weak var courseTypesCollectionView - This collectionView will display a list in horizontal of the types of Courses available, if one of the items in this collection is selected, it will change the courseListCollectionView display of Courses.
 
 Outlet weak var courseListCollectionView - This collectionView will display all the courses of a type selected previously in the view exploreCoursesList, if the user use the other collectionView to look for other types of courses, this collection will update with this information. If one of the items in the collection is selected, the user will be send to the exploreCourse view.
 
 Functions:
 
 viewDidLoad - Main func. It will call the other functions to fill the details of the exploreCoursesList.
 
 queries - This one it will help to get all the types of Courses to fill the courseTpesCollectionView and update the courseList with the courses of the type selected
 
 */

import Foundation
import UIKit
import Parse

class exploreCoursesListDetails : UIViewController{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var courseTypesCollectionView: UICollectionView!
    
    @IBOutlet weak var courseListCollectionView: UICollectionView!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var titleDataLabel: UILabel!
    
    // MARK: VARs/LETs
    
    var courseTitleType = PFObject(className: "Type") //This will help us query the type of course, it will change if the user press the typesCollection or by the information given in the previous view
    var courseListArray = [PFObject]() //Because is only one array of PFObjects, a structure was not necessary
    var courseTypeArray = [PFObject]()
    
    // MARK: MAIN FUNCTION
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.queries()
        
        //Query to get the Categorys on the Database
        courseListCollectionView.delegate = self
        courseListCollectionView.delegate = self
        courseTypesCollectionView.delegate = self
        courseTypesCollectionView.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.noDataView.isHidden = false
        self.titleDataLabel.text = "Selecciona algún tipo de curso"
        
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
    
    // MARK: OTHER FUNCTIONS
    
    func queries(){
        
        //Queries to get from the Database
        let currentDate = Date()
        
        let user = PFUser.current()
        
        print("yoberReports: \(user?["blockYobers"] as? [String] ?? [""])")
        
        let blockYobers = user?["blockYobers"] as? [String] ?? [""]
        
        blockYobers.forEach {item in
            
            let queryCourse = PFQuery(className:"Course")
            queryCourse.whereKey("type", equalTo: courseTitleType)
            queryCourse.whereKey("yober", notEqualTo: item)
            queryCourse.whereKey("active", equalTo: true)
            queryCourse.whereKey("date", greaterThan: currentDate)
            queryCourse.addDescendingOrder("view")
            
            queryCourse.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    // The find succeeded.
                    if objects.count == 0 {
                        self.noDataView.isHidden = false
                        self.titleDataLabel.text = "No hay cursos disponibles por el momento"
                    }else{
                        // The find succeeded.
                        self.courseListArray = objects
                        self.noDataView.isHidden = true
                        self.titleDataLabel.text = ""
                    }
                }
                self.courseListCollectionView.reloadData()
            }
        }
        
        let queryTypeOfCourses = PFQuery(className: "Type")
        queryTypeOfCourses.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = objects {
                // The find succeeded.
                self.courseTypeArray = object
            }
            
            self.courseTypesCollectionView.reloadData()
            
        }
        
        
    }
    
}

// MARK: COLLECTIONVIEW EXTENSION

extension exploreCoursesListDetails: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == courseTypesCollectionView){
            
            return courseTypeArray.count
            
        }
        
        return courseListArray.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == courseTypesCollectionView){
            
            let cell2 = courseTypesCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreCourseTypeCell2", for: indexPath) as! exploreCourseTypeCell2
            
            cell2.objects = courseTypeArray[indexPath.item]
            
            return cell2
            
        }
        
        let cell = courseListCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreCourseListCell2", for: indexPath) as! exploreCourseListCell2
        
        cell.objects = courseListArray[indexPath.item]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView == courseListCollectionView){
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCourse") as? exploreCourse
            
            guard let id = courseListArray[indexPath.item].objectId else{
                return
            }
            
            let course = courseListArray[indexPath.item]
            let yober = course["yober"] as? PFObject
            let yoberId = yober?.objectId
            
            viewController?.courseId = id
            viewController?.yoberObjectId = yoberId ?? ""
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
            
        }else if(collectionView == courseTypesCollectionView){
            
            courseTitleType = courseTypeArray[indexPath.item]
            self.queries()
            
        }
        
    }
    
    //Section Header
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerCourse = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "exploreHeaderCollection3", for: indexPath) as! exploreHeaderCollection
        
        guard let title = courseTitleType["name"] as? String else{
            print("The title doesnt exist")
            
            headerCourse.typeTitle = ""
            
            return headerCourse
        }
        
        headerCourse.typeTitle = title
        
        return headerCourse
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == courseListCollectionView){
            
            let widthSize = collectionView.frame.width/2 - 20
            let heightSize = widthSize/2 + 15
            
            return CGSize(width: widthSize, height: heightSize)
            
        }else{
            
         let widthSize = 150
         let heightSize = 40
         
         return CGSize(width: widthSize, height: heightSize)
            
        }
        
    }
    
}
