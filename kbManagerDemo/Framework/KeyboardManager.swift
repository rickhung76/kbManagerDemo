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
            self.textFieldDidSet(self.selectedTextField)
        }
    }
    
    private var viewController: UIViewController? {
        guard let textField = self.selectedTextField else {return nil}
        return textField.viewContainingController()
    }
    
    private var view: UIView? {
        return self.viewController?.view
    }
    
    private lazy var textFields: [UITextField] = {
        return self.view?.allSubviews.filter{$0 is UITextField} as! [UITextField]
    }()
    
    private var isScreenRaised = false
    private var oriFrameOriginY: CGFloat = 0
    private(set) var keyboardHeight: CGFloat = 0
    
    var isKeyboardDidShow = false
    var kbClickGoClosure: ((_ textField: UITextField) -> ())?
    
    //for the bottom constraint of the first subview in scroll view if it's exist
    //to enable the scrolling of scroll view after keyboard raised
    private weak var scrollView: UIScrollView?
    private weak var scrollContainerViewBottomConstraint: NSLayoutConstraint?
    var keyboardDidShowScrollYDistance: CGFloat = 0
    
    override init() {
        super.init()
        self.initNotifications()
    }
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
        
    private func textFieldDidSet(_ textField: UITextField?) {
        guard let tf = textField else {
            self.scrollView = nil
            self.scrollContainerViewBottomConstraint = nil
            return
        }
//        tf.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.initScrollView()
        self.scoll2TextField()
    }

    private func initScrollView() {
        guard let view = self.view,
            let scrollView = view.allSubviews.filter({$0 is UIScrollView}).first(where: {$0.superview == self.view}) as? UIScrollView else {return}
        self.scrollView = scrollView
        self.scrollContainerViewBottomConstraint = scrollView.getBottomConstraints().filter({ (contraint) -> Bool in
            if #available(iOS 11.0, *) {
                let isAnchored2SafeArea = (contraint.firstItem as? UILayoutGuide == view.safeAreaLayoutGuide)
                    || (contraint.secondItem as? UILayoutGuide == view.safeAreaLayoutGuide)
                
                let isAnchored2SuperView = (contraint.firstItem as? UIView == view)
                    || (contraint.secondItem as? UIView == view)
                
                return isAnchored2SafeArea || isAnchored2SuperView
                    
            } else {
                let isAnchored2SuperView = (contraint.firstItem as? UIView == self.view)
                    || (contraint.secondItem as? UIView == self.view)
                
                return isAnchored2SuperView
            }
        }).first
    }
    
    @objc private func closeKeyboard() {
        self.view?.endEditing(true)
    }
    
    func scoll2TextField() {
        DispatchQueue.main.async {
            guard let textField = self.selectedTextField,
                let scrollView = self.scrollView,
                self.scrollContainerViewBottomConstraint != nil else {return}
            let point = self.getScrollOffset(with: textField, in: scrollView, self.keyboardDidShowScrollYDistance)
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
    
    private func getScrollOffset(with textField: UIView, in scrollView: UIScrollView, _ shift: CGFloat) -> CGPoint {
        let textFieldFrame = scrollView.convert(textField.frame, from: textField.superview)
        let yOffset = textFieldFrame.origin.y - scrollView.bounds.height/2 + shift
        var y: CGFloat = 0.0
        if yOffset > 0 && yOffset < scrollView.bounds.height/2  {
            y = yOffset
        }
        else if yOffset > scrollView.center.y {
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
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeKeyboard))
        tap.cancelsTouchesInView = false
        view?.addGestureRecognizer(tap)
    }
}

//MARK: - Notification callback
extension KeyboardManager {
    // keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        print(#function)
        self.isKeyboardDidShow = true
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardSize:CGSize = keyboardFrame.size
        self.keyboardHeight = keyboardSize.height
        
        if let containerViewBottomConstraint = self.scrollContainerViewBottomConstraint {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                containerViewBottomConstraint.constant = self.keyboardHeight - window!.safeAreaInsets.bottom
            } else {
                containerViewBottomConstraint.constant = self.keyboardHeight
            }
            self.view?.layoutIfNeeded()
        } else {
            self.raiseScreen()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if let containerViewBottomConstraint = self.scrollContainerViewBottomConstraint {
             let window = UIApplication.shared.keyWindow
            if #available(iOS 11.0, *) {
                containerViewBottomConstraint.constant = -window!.safeAreaInsets.bottom
            } else {
                containerViewBottomConstraint.constant = 0
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view?.layoutIfNeeded()
            }
        } else {
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

//MARK: - UITextFieldDelegate
//extension KeyboardManager: UITextFieldDelegate {
//
//    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        switch textField.returnKeyType {
//        case .go:
//            textField.resignFirstResponder()
//            self.kbClickGoClosure?(textField)
//        case .next:
//            self.goNextTextField()
//        default:
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//}

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
    
    var allSubviews: [UIView] {
        return self.subviews.reduce([UIView]()) { $0 + [$1] + $1.allSubviews }
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
