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
    let anim = false
    
    private var backButtonImage: UIImage? {
        return UIImage(named: "button")?.withAlignmentRectInsets(UIEdgeInsets(top: 0.0, left: -12.0, bottom: -5.0, right: 0.0))
    }
    // backButton하단에 표출되는 text를 안보이게 설정
    private var backBarButtonItem: UIBarButtonItem {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .systemBackground
        return backBarButtonItem
    }
}

//MARK: - Appearance
extension CustomNavigationController {
    func setNavigationBarAppearance(_ vc:UIViewController) {
        vc.navigationItem.backBarButtonItem = backBarButtonItem
        vc.navigationController?.navigationBar.backIndicatorImage = backButtonImage
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
