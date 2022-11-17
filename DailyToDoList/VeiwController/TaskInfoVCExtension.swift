//
//  TaskInfoVCExtension.swift
//  DailyToDoList
//
//  Created by 소하 on 2022/11/17.
//

import Foundation
import UIKit


//MARK: - 키보드
extension TaskInfoViewController {
    //키보드 옵저버
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //키보드 show/hide시 view 조정
    @objc func showKeyboard(_ sender: Notification) {
        if isShow {
            return
        }
        isShow = true
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectabgle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectabgle.height
        //
        guard let keyboardHeight = keyboardHeight else {
            return
        }
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.isScrollEnabled = true
    }
    @objc private func hideKeyboard(_ sender: Notification) {
        //
        scrollView.contentInset.bottom = 0
        scrollView.isScrollEnabled = false
        isShow = false
    }
    //키보드 내리기
    func keyboardDown() {
        self.view.endEditing(true)
        isShow = false
    }
}

extension TaskInfoViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        keyboardDown()
        return true
    }
}
