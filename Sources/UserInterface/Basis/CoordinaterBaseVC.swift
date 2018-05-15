//
//  CoordinaterBaseVC.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import UIKit

/// A ViewController which is a base for coordinating the presentation of Child ViewControllers
/// It can vend Navigation Controllers to be passed through to child coordinators
/// which it will automatically present.

public class CoordinatedBaseViewController: UIViewController {
    
    private var children = [String: UIViewController]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func vendNavigationPresenter(for identifier: String) -> UINavigationController {
        let navController = UINavigationController()
        addCoordinatedChildViewController(child: navController, identifier: identifier)
        return navController
    }
    
    public func vendTabPresenter(for identifier: String) -> UITabBarController {
        let tabController = UITabBarController()
        addCoordinatedChildViewController(child: tabController, identifier: identifier)
        return tabController
    }
    
    public func addCoordinatedChildViewController(child: UIViewController, identifier: String) {
        guard children[identifier] == nil else { fatalError("Already presenting a Child ViewController with ID \(identifier)") }
        
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
        
        children[identifier] = child
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        child.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        child.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.setNeedsLayout()
    }
    
    public func removeCoordinatedChildViewController(identifier: String) {
        if let child = children[identifier] {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
            
            children[identifier] = nil
        }
        else {
            print("warning: there was no child view controller found with ID \(identifier). Skipping..")
        }
    }
    
    public func removeAllCoordinatedChildViewControllers() {
        children.forEach { (key: String, _) in
            self.removeCoordinatedChildViewController(identifier: key)
        }
    }
}
