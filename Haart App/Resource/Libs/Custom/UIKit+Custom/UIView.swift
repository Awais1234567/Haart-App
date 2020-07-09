//
//  UIView.swift
//  Dropneed
//
//  Created by Raman on 31/03/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension UIView {
    
    var isAnimating: Bool {
        return layer.animationKeys()!.count > 0
    }
    
    var isVisible: Bool {
        get {
            return !isHidden
        }
        set {
            isHidden = !newValue
        }
    }
    
//    var height: CGFloat {
//        get {
//            return bounds.size.height
//        }
//        set {
//            frame.size.height = newValue
//        }
//    }
//
//    var width: CGFloat {
//        get {
//            return bounds.size.width
//        }
//        set {
//            frame.size.width = newValue
//        }
//    }

    func actionBlock(_ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        
        let recognizer = UITapGestureRecognizer(target: sleeve, action: #selector(ClosureSleeve.invoke))
        addGestureRecognizer(recognizer)
        isUserInteractionEnabled = true
        
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func setHidden(_ hidden: Bool, animated: Bool) {
        if !animated {
            isHidden = hidden
        }
        else {
            alpha = isHidden ? 0.0 : 1.0
            isHidden = false
            UIView.animate(withDuration: 0.5, animations: {() -> Void in
                self.alpha = hidden ? 0.0 : 1.0
            }, completion: {(_ finished: Bool) -> Void in
                self.isHidden = hidden
                self.alpha = 1.0
            })
        }
    }
    
    func setVisible(_ visible: Bool, animated: Bool) {
        setHidden(!visible, animated: animated)
    }
    
    var control: UIViewController {
        return next as! UIViewController
    }
    
    var contentCompressionResistancePriority: UILayoutPriority {
        get {
            let horizontal: UILayoutPriority = contentCompressionResistancePriority(for: .horizontal)
            let vertical: UILayoutPriority = contentCompressionResistancePriority(for: .vertical)
            return UILayoutPriority(rawValue: (horizontal.rawValue + vertical.rawValue) * 0.5)
        }
        set {
            setContentCompressionResistancePriority(newValue, for: .horizontal)
            setContentCompressionResistancePriority(newValue, for: .vertical)
        }
    }
    
    var contentHuggingPriority: UILayoutPriority {
        get {
            let horizontal: UILayoutPriority = contentHuggingPriority(for: .horizontal)
            let vertical: UILayoutPriority = contentHuggingPriority(for: .vertical)
            return UILayoutPriority(rawValue: (horizontal.rawValue + vertical.rawValue) * 0.5)
        }
        set {
            setContentHuggingPriority(newValue, for: .horizontal)
            setContentHuggingPriority(newValue, for: .vertical)
        }
    }
    
    func bringSubviewToFront(_ subview: UIView, withSuperviews number: Int) {
        var subview = subview
        for _ in 0...number {
            subview.superview?.bringSubviewToFront(subview)
            subview = subview.superview!
        }
    }
    
    func addConstraint(_ view1: UIView, view2: UIView, att1: NSLayoutConstraint.Attribute, att2: NSLayoutConstraint.Attribute, mul: CGFloat, const: CGFloat) -> NSLayoutConstraint {
        if view2.responds(to: #selector(setter: self.translatesAutoresizingMaskIntoConstraints)) {
            view2.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = NSLayoutConstraint(item: view1, attribute: att1, relatedBy: .equal, toItem: view2, attribute: att2, multiplier: mul, constant: const)
        addConstraint(constraint)
        return constraint
    }
    
    func addConstraint(_ view: UIView, att1: NSLayoutConstraint.Attribute, att2: NSLayoutConstraint.Attribute, mul: CGFloat, const: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: att1, relatedBy: .equal, toItem: view, attribute: att2, multiplier: mul, constant: const)
        addConstraint(constraint)
        return constraint
    }
    
    func addConstraintSameCenterX(_ view1: UIView, view2: UIView) {
        _ = addConstraint(view1, view2: view2, att1: .centerX, att2: .centerX, mul: 1.0, const: 0.0)
    }
    
    func addConstraintSameCenterY(_ view1: UIView, view2: UIView) {
        _ = addConstraint(view1, view2: view2, att1: .centerY, att2: .centerY, mul: 1.0, const: 0.0)
    }
    
    func addConstraintSameHeight(_ view1: UIView, view2: UIView) {
        _ = addConstraint(view1, view2: view2, att1: .height, att2: .height, mul: 1.0, const: 0.0)
    }
    
    func addConstraintSameWidth(_ view1: UIView, view2: UIView) {
        _ = addConstraint(view1, view2: view2, att1: .width, att2: .width, mul: 1.0, const: 0.0)
    }
    
    func addConstraintSameCenterXY(_ view1: UIView, and view2: UIView) {
        _ = addConstraintSameCenterX(view1, view2: view2)
        _ = addConstraintSameCenterY(view1, view2: view2)
    }
    
    func addConstraintSameSize(_ view1: UIView, and view2: UIView) {
        _ = addConstraintSameWidth(view1, view2: view2)
        _ = addConstraintSameHeight(view1, view2: view2)
    }
    
    func addConstraintSameAttribute(_ attribute: NSLayoutConstraint.Attribute, subviews: [UIView]) {
        for i in 1..<subviews.count {
            addConstraint(NSLayoutConstraint(item: subviews[0], attribute: attribute, relatedBy: .equal, toItem: subviews[i], attribute: attribute, multiplier: 1.0, constant: 0.0))
        }
    }
    
    func addVisualConstraints(_ constraints: [String], subviews: [String: UIView]) {
        addVisualConstraints(constraints, metrics: nil, forSubviews: subviews)
    }
    
    func addVisualConstraints(_ constraints: [String], metrics: [String: Any]?, forSubviews subviews: [String: UIView]) {
        // Disable autoresizing masks translation for all subviews
        for subview in subviews.values {
            if subview.responds(to: #selector(setter: self.translatesAutoresizingMaskIntoConstraints)) {
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        // Apply all constraints
        for constraint in constraints {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraint, options: [], metrics: metrics, views: subviews))
        }
    }
    
    func addConstraintToFillSuperview() {
        superview?.addVisualConstraints(["H:|[self]|", "V:|[self]|"], subviews: ["self": self])
    }
    
    func addConstraintToFillSuperviewWithSafeArea() {
        superview?.addVisualConstraints(["H:|[self]|", "V:|-[self]-|"], subviews: ["self": self])
    }
    
    func addConstraintForAspectRatio(_ aspectRatio: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: aspectRatio, constant: 0.0)
        addConstraint(constraint)
        return constraint
    }
    
    func addConstraintForWidth(_ width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width)
        addConstraint(constraint)
        return constraint
    }
    
    func addConstraintForHeight(_ height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: height)
        addConstraint(constraint)
        return constraint
    }
    
    func addSubviews(_ subviews: UIView...) {
        for view in subviews {
            addSubview(view)
        }
    }
    
    var viewToImage: UIImage {
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: (image?.cgImage)!)
    }
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, 0)
       //  UIGraphicsBeginImageContext(self.bounds.size);
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }

    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
}


