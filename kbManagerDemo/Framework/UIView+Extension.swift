//
//  UIView+Extension.swift
//  KBManagerDemo
//
//  Created by 黃柏叡 on 2019/10/21.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    
    /**
    Returns the topMost UIViewController object in hierarchy.
    */
//    func topMostController() -> UIViewController? {
//
//        var controllersHierarchy = [UIViewController]()
//
//        if var topController = window?.rootViewController {
//            controllersHierarchy.append(topController)
//
//            while let presented = topController.presentedViewController {
//
//                topController = presented
//
//                controllersHierarchy.append(presented)
//            }
//
//            var matchController: UIResponder? = viewContainingController()
//
//            while let mController = matchController as? UIViewController, controllersHierarchy.contains(mController) == false {
//
//                repeat {
//                    matchController = matchController?.next
//
//                } while matchController != nil && matchController is UIViewController == false
//            }
//
//            return matchController as? UIViewController
//
//        } else {
//            return viewContainingController()
//        }
//    }
    
    /**
    Returns the UIViewController object that is actually the parent of this object. Most of the time it's the viewController object which actually contains it, but result may be different if it's viewController is added as childViewController of another viewController.
    */
//    func parentContainerViewController() -> UIViewController? {
//
//        var matchController = viewContainingController()
//        var parentContainerViewController: UIViewController?
//
//        if var navController = matchController?.navigationController {
//
//            while let parentNav = navController.navigationController {
//                navController = parentNav
//            }
//
//            var parentController: UIViewController = navController
//
//            while let parent = parentController.parent,
//                (parent.isKind(of: UINavigationController.self) == false &&
//                    parent.isKind(of: UITabBarController.self) == false &&
//                    parent.isKind(of: UISplitViewController.self) == false) {
//
//                        parentController = parent
//            }
//
//            if navController == parentController {
//                parentContainerViewController = navController.topViewController
//            } else {
//                parentContainerViewController = parentController
//            }
//        } else if let tabController = matchController?.tabBarController {
//
//            if let navController = tabController.selectedViewController as? UINavigationController {
//                parentContainerViewController = navController.topViewController
//            } else {
//                parentContainerViewController = tabController.selectedViewController
//            }
//        } else {
//            while let parentController = matchController?.parent,
//                (parentController.isKind(of: UINavigationController.self) == false &&
//                    parentController.isKind(of: UITabBarController.self) == false &&
//                    parentController.isKind(of: UISplitViewController.self) == false) {
//
//                        matchController = parentController
//            }
//
//            parentContainerViewController = matchController
//        }
//        
//        let finalController = parentContainerViewController?.parentIQContainerViewController() ?? parentContainerViewController
//
//        return finalController
//
//    }
}

