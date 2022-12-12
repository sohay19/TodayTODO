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
    @objc func showKeyboard(_ notification: NSNotification) {
        if isShow {
            return
        }
        if !(memoView.isFirstResponder || inputTitle.isFirstResponder) {
            return
        }
        isShow = true
        moveBottom(true, notification)
        scrollView.isScrollEnabled = true
        if memoView.isFirstResponder {
            scrollMemo()
        }
    }
    private func moveBottom(_ isUp:Bool, _ notification:NSNotification) {
        animateWithKeyboard(notification: notification) { [self] (keyboardFrame) in
            bottomConstraint?.constant = isUp ? keyboardFrame.height : 0
        }
    }
    private func animateWithKeyboard(notification: NSNotification, animations: ((_ keyboardFrame: CGRect) -> Void)?) {
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! Double
        
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
        
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as! Int
        let curve = UIView.AnimationCurve(rawValue: curveValue)!
        
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        ) {
            animations?(keyboardFrameValue.cgRectValue)
            self.view?.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    private func scrollMemo() {
        let padding = scrollView.contentSize.height - scrollView.bounds.size.height
        let height = padding + scrollView.contentInset.bottom
        scrollView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
    }
    @objc func hideKeyboard(_ notification: NSNotification) {
        moveBottom(false, notification)
        isShow = false
    }
    //키보드 내리기
    @objc func keyboardDown() {
        self.view.endEditing(true)
        scrollView.isScrollEnabled = false
    }
}

//MARK: - TextField
extension TaskInfoViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let changedText = currentText.replacingCharacters(in: stringRange, with: string)
        textCounter.text = "\(changedText.count)/20"
        return changedText.count < 20
    }
}

//MARK: - TextView
extension TaskInfoViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 글자 변환
        if let font = UIFont(name: K_Font_R, size: K_FontSize) {
            memoView.setLineSpacing(textView.text, font: font)
        }
        // 글자 수 세기
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        memoCounter.text = "\(changedText.count)/300"
        return changedText.count < 300
    }
}
