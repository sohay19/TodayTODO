//
//  CustomNavigationController.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/08.
//

import Foundation
import UIKit
import SideMenu

class CustomNavigationController : UINavigationController {
    
}

extension CustomNavigationController {
    //pop
    func popViewController() {
        let _ = super.popViewController(animated: false)
    }
    func popViewController(complete: @escaping () -> Void) {
        super.popViewController(animated: false)
        completeMotion(false, complete: complete)
    }
    //popRoot
    func popToRootViewController() {
        let _ = popToRootViewController(animated: false)
        completeMotion(false) { [self] in
            guard let rootVC = topViewController else {
                return
            }
            rootVC.beginAppearanceTransition(true, animated: true)
            rootVC.viewWillAppear(true)
        }
    }
    func popToRootViewController(complete: @escaping ()->Void) {
        let _ = popToRootViewController(animated: false)
        completeMotion(false) {
            complete()
        }
    }
    //push
    func pushViewController(_ viewController: UIViewController) {
        super.pushViewController(viewController, animated: false)
    }
    func pushViewController(_ viewController: UIViewController, complete: @escaping ()->Void) {
        super.pushViewController(viewController, animated: false)
        completeMotion(false, complete: complete)
    }
    //
    func completeMotion(_ animated: Bool, complete: @escaping () -> Void) {
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil, completion: { _ in
                complete()
            })
        } else {
            DispatchQueue.main.async {
                complete()
            }
        }
    }
    
}
