//
//  UIViewController.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import UIKit

extension UIViewController {

    public static func dismissOpenAlerts(base: UIViewController?) {
        // This must be run on the main thread, or else!
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                self.dismissOpenAlerts(base: base)
            }
            return
        }

        let base = base ?? UIApplication.shared.keyWindow?.rootViewController

        // If it's an alert, dismiss it
        if let alertController = base as? UIAlertController {
            alertController.dismiss(animated: false, completion: nil)
        }

        // Check all children
        if let base = base {
            for controller in base.childViewControllers {
                if let alertController = controller as? UIAlertController {
                    alertController.dismiss(animated: false, completion: nil)
                }
            }
        }

        // Traverse the view controller tree
        if let nav = base as? UINavigationController {
            dismissOpenAlerts(base: nav.visibleViewController)
        }
        else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            dismissOpenAlerts(base: selected)
        }
    }

    /// Dismiss any open alerts or action sheets
    public func dismissOpenAlerts() {
        UIViewController.dismissOpenAlerts(base: self)
    }
}
