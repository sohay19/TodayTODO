//
//  CustomNavigationController.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/08.
//

import Foundation
#if os(iOS)
import UIKit

class CustomNavigationController : UINavigationController {
    let anim = true
    
    override func viewDidLoad() {
        navigationBar.isHidden = true
    }
}


//MARK: - pop, push
extension CustomNavigationController {
    //pop
    func popViewController() {
        let _ = super.popViewController(animated: anim)
    }
    func popViewController(complete: @escaping () -> Void) {
        super.popViewController(animated: anim)
        completeMotion(anim, complete: complete)
    }
    //popRoot
    func popToRootViewController() {
        let _ = popToRootViewController(animated: anim)
        completeMotion(anim) { [self] in
            guard let rootVC = topViewController else {
                return
            }
            rootVC.beginAppearanceTransition(true, animated: true)
            rootVC.viewWillAppear(true)
        }
    }
    func popToRootViewController(complete: @escaping ()->Void) {
        let _ = popToRootViewController(animated: anim)
        completeMotion(anim) {
            complete()
        }
    }
    //push
    func pushViewController(_ viewController: UIViewController) {
        super.pushViewController(viewController, animated: anim)
    }
    func pushViewController(_ viewController: UIViewController, complete: @escaping ()->Void) {
        super.pushViewController(viewController, animated: anim)
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
#endif
