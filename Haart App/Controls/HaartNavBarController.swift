//
//  HaartNavBarController.swift
//  Haart App
//
//  Created by Stone on 26/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 80.0)
    }    
}

class HaartNavBarController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().clipsToBounds = true
        UINavigationBar.appearance().barTintColor = .red
        self.navigationBar.roundBottom()
        self.navigationBar.isTranslucent = false
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
