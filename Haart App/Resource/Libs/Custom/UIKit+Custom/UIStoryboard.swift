//
//  UIStoryboard.swift
//  Reminisce
//
//  Created by Raman on 07/03/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension UIStoryboard {

    class var main: UIStoryboard {
        let storyboardName: String = Bundle.main.object(forInfoDictionaryKey: "UIMainStoryboardFile") as! String
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
}




