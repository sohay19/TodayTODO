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
        if memoView.isFirstResponder {
            scrollMemo()
        }
    }
    private func scrollMemo() {
        let padding = scrollView.contentSize.height - scrollView.bounds.size.height
        let height = padding + scrollView.contentInset.bottom
        scrollView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
    }
    @objc func hideKeyboard(_ sender: Notification) {
        scrollView.contentInset.bottom = 0
        isShow = false
    }
    //키보드 내리기
    @objc func keyboardDown() {
        self.view.endEditing(true)
        scrollView.isScrollEnabled = false
    }
    //메모가 최상단에 오도록 스크롤
    @objc func focusedMemoView() {
        memoView.becomeFirstResponder()
        scrollMemo()
    }
}
