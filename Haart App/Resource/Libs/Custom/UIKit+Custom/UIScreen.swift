//
//  UIScreen.swift
//  Dropneed
//
//  Created by Raman on 31/03/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension UIScreen {

    class var mainBounds: CGRect {
        return main.bounds
    }
    
    class var mainSize: CGSize {
        return mainBounds.size
    }
    
    class var screenHieght: CGFloat {
        return mainBounds.size.height
    }
    
}


