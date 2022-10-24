//
//  CustomNavigationController.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/08.
//

import Foundation
import UIKit

class CustomNavigationController : UINavigationController {
    //pop
    func popViewController() {
        let _ = popViewController(animated: false)
    }
    
    func popToRootViewController() {
        let _ = popToRootViewController(animated: false)
        guard let rootVC = self.topViewController else {
            return
        }
        DispatchQueue.main.async {
            self.completeMotion(false) {
                rootVC.viewWillAppear(true)
            }
        }
    }
    func popToRootViewController(complete: @escaping ()->Void) {
        let _ = popToRootViewController(animated: false)
        DispatchQueue.main.async {
            self.completeMotion(false) {
                complete()
            }
        }
    }
}

extension CustomNavigationController {
    //Custom push
    func pushViewControllerWithLoading(_ viewController: UIViewController) {
        SystemManager.shared.openLoading(viewController)
        super.pushViewController(viewController, animated: false)
    }
    func pushViewControllerWithLoading(_ viewController: UIViewController, complete: @escaping ()->Void) {
        SystemManager.shared.openLoading(viewController)
        super.pushViewController(viewController, animated: false)
        completeMotion(false, complete: complete)
    }
    func pushViewController(_ viewController: UIViewController) {
        super.pushViewController(viewController, animated: false)
    }
    func pushViewController(_ viewController: UIViewController, complete: @escaping ()->Void) {
        super.pushViewController(viewController, animated: false)
        completeMotion(false, complete: complete)
    }
    //Custom pop
    func popViewController(complete: @escaping () -> Void) {
        super.popViewController(animated: false)
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
