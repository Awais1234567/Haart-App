//
//  Gradiant_Ext.swift
//  CardsApp
//
//  Created by Raman on 23/11/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import Foundation
import UIKit

enum Direction {
    case top
    case bottom
}

extension UIView {
    
    
    func setShadow(shadowRadius: CGFloat) -> Void { 
        self.setShadow(shadowRadius: 5, width: 4, height: 4, opacity: 0.4,color:UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7))
    }
    
    func setShadow(shadowRadius: CGFloat,width:Float,height:Float,opacity:Float,color:UIColor) -> Void {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowOffset = CGSize(width:Double(width),height: Double(height));
        self.layer.shadowOpacity = opacity;
        self.layer.shadowRadius = shadowRadius;
    }
    
    func gradiantEffect(from:Direction) {
        
        let mGradient = CAGradientLayer()
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.mainBounds.width, height: (90/568.0) * UIScreen.mainBounds.height)
        mGradient.frame = self.bounds
        var colors = [CGColor]()
        
        if from == .top {
        colors.append((self.backgroundColor?.withAlphaComponent(1).cgColor)!)
        colors.append((self.backgroundColor?.withAlphaComponent(0.2).cgColor)!)
        }
        else {
        colors.append((self.backgroundColor?.withAlphaComponent(0.2).cgColor)!)
        colors.append((self.backgroundColor?.withAlphaComponent(1).cgColor)!)
        }
        
        mGradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        mGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        mGradient.colors = colors
        self.layer.addSublayer(mGradient)
        self.backgroundColor = .clear
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        
        get{
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    
    func roundBottom() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .bottomRight],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundForMessageSender() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .topRight, .topLeft],
                                     cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundForMessageOtherUser() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .topRight, .bottomRight],
                                     cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func removeRoundBottom() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .bottomRight],
                                     cornerRadii: CGSize(width: 0, height: 0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func roundBottom( value:CGFloat){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .bottomRight],
                                     cornerRadii: CGSize(width: value, height: value))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    
    func grayViewRadiousBottm( value:CGFloat){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .bottomRight],
                                     cornerRadii: CGSize(width: value, height: value))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    
    func roundTop( value:CGFloat) {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii: CGSize(width: value, height: value))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
}
