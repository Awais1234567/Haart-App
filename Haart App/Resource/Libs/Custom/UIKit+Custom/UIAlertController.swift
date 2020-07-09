//
//  UIAlertController.swift
//  Reminisce
//
//  Created by Raman on 23/02/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    // Shows alert view with completion block
    class func alert(_ title: String, message: String, buttons: [String], completion: ((_ : UIAlertController, _ : Int) -> Void)?) -> UIAlertController {
        let alertView: UIAlertController? = self.init(title: title, message: message, preferredStyle: .alert)
        for i in 0..<buttons.count {
            alertView?.addAction(UIAlertAction(title: buttons[i], style: .default, handler: {(_ action: UIAlertAction) -> Void in
                if completion != nil {
                    completion!(alertView!, i)
                }
            }))
        }
        // Add all other buttons
        return alertView! 
    }
    
    // Shows alert view with completion block
    
    class func showAlert(_ title: String, message: String, buttons: [String], completion: ((UIAlertController, Int) -> Void)?) {
        let alertView: UIAlertController? = self.init(title: title, message: message, preferredStyle: .alert)
        for i in 0..<buttons.count {
            alertView?.addAction(UIAlertAction(title: buttons[i], style: .default, handler: {(_ action: UIAlertAction) -> Void in
                if completion != nil {
                    completion!(alertView!, i)
                }
            }))
        }
        UIApplication.visibleViewController.present(alertView!, animated: true, completion: nil)
    }
    
    //! Shows action sheet with completion block
    class func showActionSheet(_ title: String, cbTitle: String, dbTitle: String, obTitles: [String], completion: ((_ alert: UIAlertController, _ buttonIndex: Int) -> Void)?) -> UIAlertController {
        
        let alertView: UIAlertController? = self.init(title: title, message: nil, preferredStyle: .actionSheet)
        
        var inc: Int = 0
        if (dbTitle.count != 0) {
            inc += 1
            alertView?.addAction(UIAlertAction(title: dbTitle, style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
                if completion != nil {
                    completion!(alertView!, 0)
                }
            })) // Destructive button
        }
        if (cbTitle.count != 0) {
            inc += 1
            alertView?.addAction(UIAlertAction(title: cbTitle, style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                if completion != nil {
                    completion!(alertView!, dbTitle.count != 0 ? 1 : 0)
                }
            })) // Cancel button
        }
        
        for i in 0..<obTitles.count {
            alertView?.addAction(UIAlertAction(title: obTitles[i], style: .default, handler: {(_ action: UIAlertAction) -> Void in
                if completion != nil {
                    completion!(alertView!, i + inc)
                }
            }))
        } // Add all other buttons
        
        UIApplication.visibleViewController.present(alertView!, animated: true, completion: nil)
        // Show action sheet view
        return alertView!

    }
}


