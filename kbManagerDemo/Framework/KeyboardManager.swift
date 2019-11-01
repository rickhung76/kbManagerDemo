//
//  KeyboardManager.swift
//  kbManagerDemo
//
//  Created by 黃柏叡 on 2019/10/21.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation
import UIKit

class KeyboardManager: NSObject {
    static var shared = KeyboardManager()
    
    private var selectedTextField: UITextField? {
        didSet {
            if let textField = self.selectedTextField {
                self.textFieldSelected(textField)
            }
            else {
                self.textFieldDeselected(oldValue)
            }
        }
    }
    
    private var viewController: UIViewController? {
        guard let textField = self.selectedTextField else {return nil}
        return textField.viewContainingController()
    }
    
    private var view: UIView? {
        return self.viewController?.view
    }
    
    private var textFields: [UITextField] {
        return self.view?.allSubviews(is: UITextField.self) ?? []
    }
    
    private var isScreenRaised = false
    private var oriFrameOriginY: CGFloat = 0
    private(set) var keyboardHeight: CGFloat = 0
    
    var isKeyboardDidShow = false
    var keyboardDidShowScrollYDistance: CGFloat = 0
    
    var isEnable: Bool = false {
        didSet {
            if self.isEnable {
                self.initNotifications()
            }
            else {
                self.deinitNotifications()
            }
        }
    }

    private weak var _retainedScrollView: UIScrollView?
    private var _retainedGestureRecognizer: UIGestureRecognizer?
}

extension KeyboardManager {
    private func initNotifications() {
        // Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // TextFields
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldViewDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldViewDidEndEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func deinitNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func textFieldDeselected(_ textField: UITextField?) {
        self.removeTappedAround(textField)
        self._retainedScrollView = nil
    }
        
    private func textFieldSelected(_ textField: UITextField) {
        self.getScrollView()
        if let _ = self._retainedScrollView {
            self.hideKeyboardWhenPanDown()
        }
        else {
            self.hideKeyboardWhenTappedAround()
        }
    }

    private func getScrollView() {
        guard let view = self.view,
            let scrollView = view.allSubviews(is: UIScrollView.self).first(where: {$0.superview == self.view}) else {return}
        self._retainedScrollView = scrollView
        self._retainedScrollView!.keyboardDismissMode = .interactive
    }
    
    private func scoll2TextField() {
        DispatchQueue.main.async {
            guard let textField = self.selectedTextField,
                let scrollView = self._retainedScrollView else {return}
            let point = self.getScrollOffset(with: textField,
                                             in: scrollView,
                                             shift: self.keyboardDidShowScrollYDistance)
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    private func raiseScreen() {
        guard let selectedTextField = selectedTextField, let view = self.view else {return}
        self.oriFrameOriginY = view.frame.origin.y
        let distance: CGFloat = 100
        let locationY = (selectedTextField.superview == nil) ? selectedTextField.frame.origin.y: selectedTextField.superview!.convert(selectedTextField.frame, to: view).origin.y
        let threshold = view.frame.size.height - keyboardHeight
        
        if(locationY > (threshold - distance)) {
            let moveDistance: CGFloat = (threshold - distance) - locationY
            UIView.animate(withDuration: 0.4, animations: {
                view.frame = CGRect(x: 0, y: moveDistance, width: view.frame.size.width, height: view.frame.size.height)
            }) { (isCompleted) in
                self.isScreenRaised = true
            }
        }
    }
    
    private func descentScreen() {
        guard self.isScreenRaised == true, let view = self.view else {return}
        UIView.animate(withDuration: 0.4, animations: {
            view.frame = CGRect(x: 0, y: self.oriFrameOriginY, width: view.frame.size.width, height: view.frame.size.height)
        }) { (isCompleted) in
            self.isScreenRaised = false
        }
    }
    
    private func getScrollOffset(with textField: UIView, in scrollView: UIScrollView, shift: CGFloat) -> CGPoint {
        let textFieldFrame = scrollView.convert(textField.frame, from: textField.superview)
        let yOffset = textFieldFrame.origin.y - scrollView.bounds.height/2 + shift
        var y: CGFloat = 0.0
        if yOffset > 0 && yOffset < scrollView.bounds.height/2  {
            y = yOffset
        }
        else if yOffset >= scrollView.bounds.height/2 {
            y = scrollView.contentSize.height - scrollView.bounds.height
        }
        return CGPoint(x: 0, y: y)
    }
    
    func hasNextTextField() -> Bool {
        guard let textField = self.selectedTextField else { return false }
        
        guard let index = textFields.firstIndex(of: textField) else { return false }
        
        return index < textFields.count-1
    }
    
    func goNextTextField() {
        guard let textField = self.selectedTextField else { return }
        
        guard let index = textFields.firstIndex(of: textField) else { return }
        
        guard index < textFields.count-1 else { return }
        
        let nextTextField = textFields[index+1]
        
        let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
        
        if isAcceptAsFirstResponder == false {
            view?.endEditing(true)
        }
    }
    
    func hideKeyboardWhenPanDown() {
        guard let view = self._retainedScrollView else {return}
        _retainedGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        _retainedGestureRecognizer!.delegate = self
        _retainedGestureRecognizer!.cancelsTouchesInView = false
        view.addGestureRecognizer(_retainedGestureRecognizer!)
    }
    
    @objc func handlePan(recognizer:UIPanGestureRecognizer) {
        guard let viewHeight = self.view?.bounds.height else {return}
        let locationY = recognizer.location(in: self.view).y
        let diff:CGFloat = viewHeight - locationY
        print("(\(keyboardHeight), \(diff))")
        self._retainedScrollView?.contentInset.bottom = diff
    }
    
    private func hideKeyboardWhenTappedAround() {
        guard let view = self.view else {return}
        _retainedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeKeyboard))
        _retainedGestureRecognizer!.cancelsTouchesInView = false
        view.addGestureRecognizer(_retainedGestureRecognizer!)
    }
    
    private func removeTappedAround(_ textField: UITextField?) {
        guard let tf = textField,
            let vc = tf.viewContainingController(),
            let view = vc.view,
            let tapGesture = self._retainedGestureRecognizer else {return}
        view.removeGestureRecognizer(tapGesture)
        self._retainedGestureRecognizer = nil
    }
    
    @objc private func closeKeyboard() {
        self.view?.endEditing(true)
    }
}

//MARK: - Notification callback
extension KeyboardManager {
    // keyboard
    @objc internal func keyboardWillShow(notification: NSNotification) {
        guard let vc = self.viewController else {return}
        print(#function)
        self.isKeyboardDidShow = true
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardSize:CGSize = keyboardFrame.size
        self.keyboardHeight = keyboardSize.height

        if let scrollView = self._retainedScrollView {
            var height: CGFloat = 0
            if #available(iOS 11.0, *) {
                let safeAreaInsetsBottom: CGFloat = vc.view.safeAreaInsets.bottom
                height = self.keyboardHeight - safeAreaInsetsBottom
            } else {
                let tabBarHeight: CGFloat = vc.tabBarController?.tabBar.frame.height ?? 0.0
                height = self.keyboardHeight - tabBarHeight
            }
            scrollView.contentInset.bottom = height
            self.scoll2TextField()
        }
        else {
            self.raiseScreen()
        }
    }
    
    @objc internal func keyboardWillHide(notification: NSNotification){
        print(#function)
        guard let _ = self.viewController else {return}

        if let scrollView = self._retainedScrollView {
            scrollView.contentInset.bottom = 0
        }
        else {
            self.descentScreen()
        }
        isKeyboardDidShow = false
    }
    
    // TextField
    @objc internal func textFieldViewDidBeginEditing(_ notification: Notification) {
        print(#function)
        selectedTextField = notification.object as? UITextField
    }
    
    @objc internal func textFieldViewDidEndEditing(_ notification: Notification) {
        print(#function)
        selectedTextField = nil
    }
    
    @objc internal func textDidChangeNotification(_ notification: Notification) {
        print("\(#function)\n\(notification)")
    }
}


fileprivate extension UIView {
    func getAllConstraints() -> [NSLayoutConstraint] {
        var views = [self]
        var view = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }

        return views.flatMap({ $0.constraints }).filter { constraint in
            return constraint.firstItem as? UIView == self ||
                constraint.secondItem as? UIView == self
        }
    }
    
    func getBottomConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .bottom && $0.firstItem as? UIView == self) ||
            ($0.secondAttribute == .bottom && $0.secondItem as? UIView == self)
        } )
    }

    func allSubviews<T>(is type: T.Type) -> [T] {
        let views = self.subviews.reduce([UIView]()) { $0 + [$1] + $1.allSubviews(is: T.self) }
        return views.filter({$0 is T}) as! [T]
    }
        
    /**
    Returns the UIViewController object that manages the receiver.
    */
    func viewContainingController() -> UIViewController? {
        
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
    }
}

//MARK: - UIGestureRecognizerDelegate
extension KeyboardManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
