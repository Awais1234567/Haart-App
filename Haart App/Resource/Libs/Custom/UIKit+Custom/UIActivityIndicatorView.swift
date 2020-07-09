//
//  UIActivityIndicatorView.swift
//  Reminisce
//
//  Created by Raman on 23/02/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {

    var setAnimating: Bool {
        get {
            return true
        }
        set {
            if newValue {
                self.startAnimating()
            } else {
                self.stopAnimating()
            }
        }
    }
    
}


