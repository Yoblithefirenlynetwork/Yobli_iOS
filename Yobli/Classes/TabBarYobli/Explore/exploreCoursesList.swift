//
//  exploreCoursesList.swift
//  Yobli
//
//  Created by Humberto on 8/3/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/* MARK: MAIN INFORMATION
 
 Class exploreCourseList
 
 This class will display an array of collection views that will show different types of course, limit to four, depending of what is selected it could send you to exploreCourseListDetails to check more details of an specific type of Course or go to exploreCourse to check all the details about an specific single course.
 
 Structure:
 
 struct_courseWTypes: Is a struct that will help us in the creation of the different sections for the variable Outlet courseListCollectionView
 
    - typeName : Will save the type of Courses that will be saved in this struct
    - numberOfCourses : Check the number of courses that are in this struct
    - courseTypes: Is the PFObject array where the courses retrieved will be saved
 
 Variables:
 
 Outlet weak var courseTypesCollectionView - This collectionView will display a list in horizontal of the types of Courses available, if one of the items in this collection is selected, it will send the user to the next view exploreCoursesList, so it can display all the available courses of a certain type.
 
 Outlet weak var courseListCollectionView - This collectionView will be creating new sections depending on the number of types of courses available, with a limit of showing fours courses per type, it will have a header to show the name type and a bottom where a button can be press and send the user to the exploreCourseList, so it can display all the available courses of a certain type and not only a limit of four. If one of the items inside any of the sections created, the user will be send to the class exploreCourse to check all the details about an specific single course.
 
 Functions:
 
 viewDidLoad - Main func. It will call the other functions to fill the details of the exploreCoursesList.
 
 queries - This one it will help to get all the types of Courses to fill the courseTpesCollectionView, then use this types to do another query in querieFromTypes.
 
 querieFromTypes - After the queries function is done, it will call this function to do a new query of PFObjects and fill the an array of struct_courseWTypes, so it can fill the courseListCollectionView
 
 passData - Is a function to send the type name to the exploreCoursesListDetails, this is function by a the button in the bottom of each section of the courseListCollectionView, is called thanks to the delegate: exploreToCourseDelegate
 
 */

import Foundation
import UIKit
import Parse

// MARK: STRUCTURE

struct struct_courseWTypes {
    var typeName: String
    var numberOfCourses: Int
    var courseType = [PFObject]()
    var type: PFObject
}

// MARK: MAIN CLASS

class exploreCoursesList : UIViewController, exploreToCourseDelegate{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var courseTypesCollectionView: UICollectionView!
    
    @IBOutlet weak var courseListCollectionView: UICollectionView!
    
    // MARK: VARs/LETs
    
    var courseTypes = [PFObject]() //Here we will save the results from queries
    var courseNewTypes = [String]() //Here we will put the names of the queries that arent empty type courses
    var courseListArray = [struct_courseWTypes]() //Importan array of structure
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.queries()
        
        courseTypesCollectionView.delegate = self
        courseTypesCollectionView.dataSource = self
        courseListCollectionView.delegate = self
        courseListCollectionView.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
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
    
    // MARK: OTHER FUNCTIONS
    
    func queries(){
        
        //We will do a query to Types to get all the types of Courses that they are
        
        let queryTypeOfCourses = PFQuery(className: "Type")
        queryTypeOfCourses.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = objects {
                // The find succeeded.
                self.courseTypes = object //save this types to later fill the TypestCollectionView
                self.querieFromTypes(noTypes: self.courseTypes.count) //This function can only be call if the query is a success.
                
            }
            
        }
        
    }
    
    func querieFromTypes(noTypes: Int){
        
        var x = 0 //This variable is to help to fill courseListArray
        
        while x < noTypes { //We check that x is less than the number of course types
            
            if let newCourseType : String = self.courseTypes[x]["name"] as? String{ //Get the type name, it should always work, because in the database you cannot create a type without a name
                
                let newType = self.courseTypes[x]
                
                let currentDate = Date()
                
                let queryByType = PFQuery(className: "Course") //Call a query to the class Course
                queryByType.whereKey("type", equalTo: self.courseTypes[x]) //It should have the same courseType
                queryByType.whereKey("active", equalTo: true) //It should be active, this is important because the active courses usually are the ones who are not yet given or graded
                queryByType.whereKey("date", greaterThan: currentDate)
                queryByType.addDescendingOrder("view")
                
                queryByType.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
                    
                    if let error = error {
                        // Log details of the failure
                        print(error.localizedDescription)
                    } else if let object = objects {
                        // The find succeeded.
                        
                        if(object.count > 0){
                            
                            let newCourseTypeStructure = struct_courseWTypes(typeName: newCourseType, numberOfCourses: object.count, courseType: object, type: newType) //Create a struct that will save all the courses, its numbers and the type of courses they are.
                            
                            
                            self.courseNewTypes.append(newCourseType)
                            self.courseListArray.append(newCourseTypeStructure) //Then this struct will be added to the courselistArray
                            
                        }
                        
                    }
                    
                    self.courseListCollectionView.reloadData() //reloadData to update the collectionview with the changes
                    self.courseTypesCollectionView.reloadData()
                    
                }
                
            }else{
                
                print("It didnt work")
                
            }
            
            x = x + 1 //Then add a value more to x after doing the previous step to keep going on the loop
            
        }
        
    }
    
    func passData(typeToWatch: PFObject){
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCoursesListDetails") as? exploreCoursesListDetails
        
        viewController?.courseTitleType = typeToWatch //Type of course that you want to see more about
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
}

// MARK: COLLECTIONVIEW EXTENSION

extension exploreCoursesList: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if(collectionView == courseListCollectionView){

            return courseNewTypes.count //The number of sections is equivalent to the number of struct served in the array, each struct represents a type of Course
            
        }else{
            
            return 1
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == courseListCollectionView){
            
            if(courseListArray[section].numberOfCourses <= 4){ //To make sure that are no more than 4 Courses being displayed for section
                
                return courseListArray[section].numberOfCourses
                
            }else{
                
                return 4
                
            }
            
        }else{ //This is in case the other collection view is the type one
            
            return courseTypes.count
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == courseListCollectionView){
            
            let cell2 = courseListCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreCourseListCell1", for: indexPath) as! exploreCourseListCell1
            
            cell2.objects = courseListArray[indexPath.section].courseType[indexPath.item] //Send the PFObject of Course
            
            return cell2
            
        }
        
        let cell = courseTypesCollectionView.dequeueReusableCell(withReuseIdentifier: "exploreCourseTypeCell1", for: indexPath) as! exploreCourseTypeCell1
        
        cell.objects = courseTypes[indexPath.item] //Send the PFObject of Type
        
        return cell
        
    }
    
    //What happen if you select an item of the sections of the collectionView
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView == courseListCollectionView){
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCourse") as? exploreCourse
            
            guard let id = courseListArray[indexPath.section].courseType[indexPath.item].objectId else{
                return
            }
            
            viewController?.courseId = id
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
            
        }else if(collectionView == courseTypesCollectionView){
                
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCoursesListDetails") as? exploreCoursesListDetails
                
            viewController?.courseTitleType = courseTypes[indexPath.item]
            print("se manda: \(courseTypes[indexPath.item])")
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }
        
    }
    
    //Section Header Up and Down
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionFooter:
                
            let footerCourse = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "exploreCourseSectHeadDown", for: indexPath) as! exploreCourseSectHeadDown
               
            footerCourse.delegate = self //This done so the button inside of the Footer is selectable, we created a delegate inside the footer
            footerCourse.typeToGo = courseListArray[indexPath.section].type //This is done so it can be now what type of what section is being wanted to see more.
                
            return footerCourse
            
        default:
            
            let headerCourse = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "exploreHeaderCollection2", for: indexPath) as! exploreHeaderCollection
            
            headerCourse.typeTitle = courseListArray[indexPath.section].typeName
            
            return headerCourse

        }
        
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
