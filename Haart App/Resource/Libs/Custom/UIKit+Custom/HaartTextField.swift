//
//  HaartView.swift
//  Haart App
//
//  Created by Stone on 11/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

class HaartTextField: UITextField {

    let padding = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.init(red: 243/255.0, green: 244/255.0, blue: 245/255.0, alpha: 1).cgColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        if(self.keyboardType == .phonePad) {
            return bounds.inset(by: UIEdgeInsets.init(top: 10, left: 110, bottom: 10, right: 20))
        }
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if(self.keyboardType == .phonePad) {
            return bounds.inset(by: UIEdgeInsets.init(top: 10, left: 110, bottom: 10, right: 20))
        }
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        if(self.keyboardType == .phonePad) {
            return bounds.inset(by: UIEdgeInsets.init(top: 10, left: 110, bottom: 10, right: 20))
        }
        return bounds.inset(by: padding)
    }
    
   
}
