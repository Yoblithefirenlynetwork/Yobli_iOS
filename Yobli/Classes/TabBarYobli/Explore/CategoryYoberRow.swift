//
//  CategoryYoberRow.swift
//  Yobli
//
//  Created by Brounie on 17/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse
import Foundation

class CategoryYoberRow: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var yoberCollection: UICollectionView!
    @IBOutlet weak var yoberSection: UILabel!
    
    weak var delegate1: CourseRowDelegate?
    weak var delegate2: ServiceRowDelegate?
    weak var delegate3: GalleryRowDelegate?
    
    let courseCellId = "exploreYoberCourseCell"
    let serviceCellId = "exploreYoberServiceCell"
    let galleryCellId = "exploreYoberGalleryCell"
    
    var yoberCoursesArray = [PFObject]()
    var yoberServicesArray = [PFObject]()
    var yoberGalleryArray = [PFObject]()
    
    var actualSection = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let courseCell = UINib(nibName: courseCellId, bundle: nil)
        yoberCollection.register(courseCell, forCellWithReuseIdentifier: courseCellId)
        
        let serviceCell = UINib(nibName: serviceCellId, bundle: nil)
        yoberCollection.register(serviceCell, forCellWithReuseIdentifier: serviceCellId)
        
        let galleryCell = UINib(nibName: galleryCellId, bundle: nil)
        yoberCollection.register(galleryCell, forCellWithReuseIdentifier: galleryCellId)
        
        yoberCollection.dataSource = self
        yoberCollection.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CategoryYoberRow : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(actualSection == "Cursos"){
            print("cursos: \(yoberCoursesArray.count)")
            return yoberCoursesArray.count
            
        }else if(actualSection == "Servicios"){
            
            return yoberServicesArray.count
            
            
        }
            
        return yoberGalleryArray.count

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if(actualSection == "Cursos"){
            
            return CGSize(width: 80, height: 100)
            
        }else if(actualSection == "Servicios"){
            
            return CGSize(width: 120, height: 120)
            
        }
            
        return CGSize(width: 200, height: 120)
            
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if(actualSection == "Servicios"){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: serviceCellId, for: indexPath) as! exploreYoberServiceCell
            cell.objects = yoberServicesArray[indexPath.item]
            return cell
            
        }else if(actualSection == "Galeria"){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: galleryCellId, for: indexPath) as! exploreYoberGalleryCell
            cell.objects = yoberGalleryArray[indexPath.item]
            return cell
            
        }
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: courseCellId, for: indexPath) as! exploreYoberCourseCell
            
        cell.objects = yoberCoursesArray[indexPath.item]
            
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if delegate1 != nil {
            delegate1?.cellCourse(position: indexPath.item)
        }else if delegate2 != nil{
            delegate2?.cellService(position: indexPath.item)
        }else if delegate3 != nil{
            delegate3?.cellGallery(position: indexPath.item)
        }
        
    }
    

}
