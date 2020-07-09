//
//  HaartTabViewCotroller.swift
//  Haart App
//
//  Created by Stone on 26/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

class HaartTabViewCotroller: UITabBarController {

    let button = UIButton.init(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarView?.backgroundColor = .red
        self.tabBar.tintColor = UIColor.red
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        button.layer.cornerRadius = 37
        button.setBackgroundImage(UIImage.init(named: "Home"), for: .normal)
        button.addTarget(self, action: #selector(homeBtnPressed), for: .touchUpInside)
        self.view.insertSubview(button, aboveSubview: self.tabBar)

        let bgView = UIImageView.init(frame: CGRect.init(x: 0, y: self.view.bounds.height - 105, width: UIScreen.main.bounds.width, height: 100))
        bgView.image = UIImage.init(named: "tabBg")
        self.tabBar.insertSubview(bgView, at: 5)
     //     self.tabBar.layer.insertSublayer(bgView.layer, at: 0)
     //   addShape()
     //    self.tabBar.layer.sublayers?[2].backgroundColor = UIColor.red.cgColor
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
      //  self.tabBar.barTintColor = UIApplication.visibleViewController.view.backgroundColor
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // safe place to set the frame of button manually
        if #available(iOS 11.0, *) {
            if(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > CGFloat.init(5.0)) {
                button.frame = CGRect.init(x: self.tabBar.center.x - 37, y: self.view.bounds.height - 125, width: 74, height: 74)
            }
            else {
                button.frame = CGRect.init(x: self.tabBar.center.x - 37, y: self.view.bounds.height - 90, width: 74, height: 74)
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func homeBtnPressed() {
        self.selectedIndex = 2
    }

}
