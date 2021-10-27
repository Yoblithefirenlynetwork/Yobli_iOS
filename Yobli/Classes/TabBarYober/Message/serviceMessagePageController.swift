//
//  serviceMessagePageController.swift
//  Yobli
//
//  Created by Brounie on 15/12/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit

class serviceMessagePageController: UIPageViewController, goToPageCreate, goToPageEdit {
    
    //THIS FOR THE MOMENT YOU SEND A SERVICE
    
    weak var messagePrivatePrevious : messagePrivate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            
            setViewControllers([firstViewController],
                                direction: .forward,
                                animated: true,
                                completion: nil)
            
        }
        
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        return [self.newViewController(name: "editFromExistenceService"),
                self.newViewController(name: "createPrivateService")]
        
    }()

    private func newViewController(name: String) -> UIViewController {
        
        if name == "editFromExistenceService"{
            
            let viewController = UIStoryboard(name: "TabYoberMessage", bundle: nil).instantiateViewController(withIdentifier: "\(name)") as? editFromExistenceService
            
            viewController?.delegate = self
            viewController?.messagePrivatePrevious = messagePrivatePrevious
            
            return viewController!
            
        }else{
            
            let viewController = UIStoryboard(name: "TabYoberMessage", bundle: nil).instantiateViewController(withIdentifier: "\(name)") as? createPrivateService
            
            viewController?.delegate = self
            viewController?.messagePrivatePrevious = messagePrivatePrevious
            
            return viewController!
            
        }
        
    }
    
    func buttonTapSecond() {
        
        print("Send to create")
        
        if let viewController = orderedViewControllers.last as? createPrivateService {
            viewController.delegate = self
            self.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    func buttonTapFirst(){
        
        print("Send to edit")
        
        if let viewController = orderedViewControllers.first as? editFromExistenceService {
            viewController.delegate = self
            self.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
        }
        
    }

}
    
// MARK: UIPageViewControllerDataSource

extension serviceMessagePageController: UIPageViewControllerDataSource {
 
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
                
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
                
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
                
        return orderedViewControllers[nextIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
                
        let previousIndex = viewControllerIndex - 1
                
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
                
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
                
        return orderedViewControllers[previousIndex]
        
    }
    
}
