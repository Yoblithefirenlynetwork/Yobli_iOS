//
//  exploreCategoryMain.swift
//  Yobli
//
//  Created by Humberto on 7/27/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

/* MARK: MAIN INFORMATION
 
 Class exploreCategoryMain
 
 This class is to show the Yobers that offers services of a selected Category.
 
 Variables:
 
 Outlet weak var categoryTitle - Label that will display the category name selected
 
 Outlet weak var categoryLogo - Display the logo image of the category selected
 
 Outlet weak var yoberCategoryArray - Display the arrays of yobers that provide services of the same category.
 
 Functions:
 
 viewDidLoad - Main func. It will call the other functions to fill the yoberCategoryArray Collection View.
 
 updateView - In charge of updating the received data from other views
 
 queries - In charge of getting certain information to fill tableView or CollectionView, depending on the views
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 Extensions
 
 CollectionView - This is where all the important details to fill one of multiple cells will be sorted, will receive data given by updateView or Queries depending.
 
 */

import Foundation
import UIKit
import Parse

class exploreCategoryMain: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryLogo: UIImageView!
    @IBOutlet weak var yoberCategoryArray: UICollectionView!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var titleNoDataLabel: UILabel!
    
    //MARK: VARs/LETs
    
    var objects = PFObject(className: "Category") //This var wil receive the data from the previous view, exploreMain
    
    var usersCategory = [PFObject]() //This array will be filled with the Yobers data to fill the CollectionView
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView() //Update the first two Outlets(image,label) with the objects data
        self.queries() //Do a querie to fill the CollectionView
        
        //Important part to make the CollectionView work
        yoberCategoryArray.delegate = self
        yoberCategoryArray.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.noDataView.isHidden = true
        self.titleNoDataLabel.text = "No hay servicios disponibles por el momento."
        
        self.categoryLogo.layer.cornerRadius = self.categoryLogo.frame.size.width / 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func goToSearch(_ sender: UIButton) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "searchController") as? searchController
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    //MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        if let imageInformation = objects["logo"] as? PFFileObject{ //This is done, so it doesn't send an error, it only shows an empty space, but then you will now something is not right
            
            //This getDataInBackground is to make Pass the PFFileObject to Data
            
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData) //The Data becomes a UIImage
                    
                    self.categoryLogo.image = image
                }
                    
            }
            
        }else{
            self.categoryLogo.image = nil
        }
        
        if let newName = objects["name"] as? String{ //This is done, so it doesn't send an error, it only shows an empty space, but then you will now something is not right
            categoryTitle.text = newName
        }else{
            categoryTitle.text = nil
        }
        
    }
    
    func queries(){
            
        // This query is a combination or merge of two queries
            
        //First get a query from Service where you can get all the Services that are from a certain category and are active
        
        let user = PFUser.current()
        
        let blockYobers = user?["blockYobers"] as? [String] ?? [""]
        
        blockYobers.forEach {item in
            
            let queryGetYobers = PFQuery(className: "_User")
            queryGetYobers.whereKey("objectID", notEqualTo: item)
            queryGetYobers.whereKey("yober", equalTo: true)
            queryGetYobers.whereKey("category", equalTo: objects["name"] as? String ?? "")
            
            queryGetYobers.findObjectsInBackground() {(yobers, error) in
                
                if error == nil, let yobers = yobers {
                    
                    self.usersCategory = yobers
                    if self.usersCategory.count == 0 {
                        self.noDataView.isHidden = false
                    }else{
                        self.noDataView.isHidden = true
                        self.yoberCategoryArray.reloadData()
                    }
                }else{
                    print(error?.localizedDescription ?? "Error en yobers")
                }
            }
        }
    }
}

// MARK: COLLECTIONVIEW EXTENSION

extension exploreCategoryMain: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return usersCategory.count //When you get the querie result from the function queries you will get between 0 or more Yobers
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = yoberCategoryArray.dequeueReusableCell(withReuseIdentifier: "exploreCategoryMainCell", for: indexPath) as! exploreCategoryMainCell //Connect to the Cell and its code in ExploreMainCell
        
        cell.objects = usersCategory[indexPath.item] //Send a value from the array, if the array is empty or nil, dont worry it will not send an error
        
        return cell
        
    }
    
    //If a cell is press this will happen
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Send the yoberId ( this is done because you cannot send the data between other views, this if different from the other type of classes in the database, Users is the only one not allowed ), to the exploreYoberProfile that is the view in charge to show the User all the relevant information from the Yober
            
        let  yoberObject = usersCategory[indexPath.item]
        let yoberId = yoberObject.objectId
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile
        
        viewController?.yoberId = yoberId ?? ""
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
//        if let yober = usersCategory[[indexPath.item] as? {//["yober"] as? PFObject, let yoberId = yober.objectId{
//
//            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile
//
//            viewController?.yoberId = yoberId
//
//            self.navigationController?.pushViewController(viewController!, animated: true)
//
//        }else{
//
//            print("Should not be possible, there is always and objectId in any PFObject already saved")
//
//        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthSize = collectionView.frame.width/2 - 20
        let heightSize = widthSize/2 + 15
        
        return CGSize(width: widthSize, height: heightSize)
        
    }
    
    
}
