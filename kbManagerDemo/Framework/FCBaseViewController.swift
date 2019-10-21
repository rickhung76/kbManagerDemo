//
//  FCBaseViewController.swift
//  FCamera
//
//  Created by Frank Chen on 2018/11/27.
//  Copyright © 2018年 Frank Chen. All rights reserved.
//

import UIKit

public class FCBaseViewController: UIViewController {
    
    //MARK: - Life Cycle
    public init() {
        let className = NSStringFromClass(type(of: self))
        let bundle:Bundle = Bundle(for: NSClassFromString(className)!)
        let xibName = className.components(separatedBy: ".").last!
        super.init(nibName: xibName, bundle: bundle)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        //沒印這行注意有記憶體未被釋放
        print("deinit: \(type(of: self))")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: 1
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            self.scrollContainerViewBottomConstraint?.constant = -window!.safeAreaInsets.bottom
//        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    public func presentFromViewController(ViewController VC:UIViewController, animated:Bool = true) {
        if let navigationController =  VC.navigationController {
            navigationController.pushViewController(self, animated: animated) }
        else {
            VC.present(self, animated: true, completion: nil)
        }
    }
    
    public func dismiss(toRootVC: Bool = false) {
        if(self.navigationController != nil) {
            if toRootVC {
                _ = self.navigationController?.popToRootViewController(animated: true)
            } else {
                _ = self.navigationController?.popViewController(animated: true);
            }
        } else {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
        }
    }
}

//MARK: - Navigation
extension FCBaseViewController {
    public func setNavigationEmptyBack() {
        let btnBack = UIButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let btnBackBarButtonItem = UIBarButtonItem.init(customView: btnBack)
        btnBackBarButtonItem.style = .plain
        btnBackBarButtonItem.title = ""
        self.navigationItem.leftBarButtonItem = btnBackBarButtonItem
    }
    
    public func setNavigationBack(_ action: Selector? = nil, setImage: UIImage? = nil) {
        let btnBack = UIButton.init(frame: CGRect(x: 0, y: 0, width: 34, height: 28))
        btnBack.setImage(setImage ?? UIImage.init(named: "btn_back_n"), for: .normal)
        btnBack.setImage(setImage ?? UIImage.init(named: "btn_back_n"), for: .highlighted)
        btnBack.imageView?.contentMode = .scaleAspectFit
        btnBack.contentVerticalAlignment = .fill
        btnBack.contentHorizontalAlignment = .left
        btnBack.addTarget(self, action: action ?? #selector(btnBackPressed(sender:)), for: .touchUpInside)
        
        let btnBackBarButtonItem = UIBarButtonItem.init(customView: btnBack)
        btnBackBarButtonItem.style = .plain
        btnBackBarButtonItem.title = ""
        self.navigationItem.leftBarButtonItem = btnBackBarButtonItem
    }
    
    public func setNavigationClose(_ action: Selector? = nil, setImage: UIImage? = nil) {
        let btnBack = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let widthConstraint = NSLayoutConstraint(item: btnBack, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35.0)
        let heightConstraint = NSLayoutConstraint(item: btnBack, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35.0)
        btnBack.addConstraints([widthConstraint, heightConstraint])
        
        btnBack.setImage(setImage ?? UIImage(named: "btn_close"), for: .normal)
        btnBack.setImage(setImage ?? UIImage(named: "btn_close"), for: .highlighted)
        btnBack.imageView?.contentMode = .scaleAspectFit
        btnBack.contentVerticalAlignment = .fill
        btnBack.contentHorizontalAlignment = .left
        btnBack.addTarget(self, action: action ?? #selector(btnDismissPressed(sender:)), for: .touchUpInside)
        
        let btnBackBarButtonItem = UIBarButtonItem.init(customView: btnBack)
        btnBackBarButtonItem.style = .done
        btnBackBarButtonItem.title = ""
        self.navigationItem.rightBarButtonItem = btnBackBarButtonItem
    }
    
    @objc func btnBackPressed(sender: Any?) {
        self.dismiss()
    }
    
    @objc func btnDismissPressed(sender: Any?) {
        if let nav = self.navigationController {
            nav.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss()
        }
    }
}

 
extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}
