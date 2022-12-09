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
        //메모 터치 시
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
