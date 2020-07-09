//
//  AbstractControl.swift
//  FusumaExample
//
//  Created by Raman on 14/11/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit
import SwiftMessages
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import CoreLocation
import SDWebImage
 
class AbstractControl: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let db = Firestore.firestore()
    var user:User! //Auth.auth().currentUser
    var likesCountLbl = UILabel()
    var matchesCountLbl = UILabel()
    var userReference: CollectionReference {
        return db.collection("users")
    }
    var userDocument:QueryDocumentSnapshot?
    
    let BUTTONS_SPACING:CGFloat = 7.0
 
    var smallBtnSize:CGSize {
        return CGSize(width: 40, height: 35)
    }
    
    enum BarButtonSide {
        case left
        case right
    }
    
    //MARK: Default Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            self.user = user
        }
        let logo = UIImage(named: "Logo_Small")
        let imageView = UIImageView(image:logo)
        imageView.frame.size = CGSize.init(width: 60, height: 52)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       locationManager.stopUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
        //self.tabBarController?.tabBar.barTintColor = UIApplication.visibleViewController.view.backgroundColor
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /******************************************************/
    
    //MARK: Text field delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /******************************************************/
    
}

// Nav Bar Multiple buttons

typealias NavbarBtuttons = AbstractControl
extension NavbarBtuttons {
    
    func setNavBarButtons(letfImages:[UIImage]?,rightImage:[UIImage]?) {
        
        if letfImages != nil {
            self.setLeftBarBtns(images: letfImages!)
        }
        
        if rightImage != nil {
            self.setRightBarBtns(images: rightImage!)
        }
        
    }
    
    /************ SET LEFT BUTTONS *******************/
    private func setLeftBarBtns(images:[UIImage]) {
        let leftView = UIView()
        var x:CGFloat = 0.0
        var tag = 0
        for image in images {
            let btn = self.createButton(withImage: image,xPosition:x, side:.left)
            tag += 1
            btn.tag = tag
            leftView.addSubview(btn)
            
            
            let matchesImage = UIImage.init(named: "lover")
            if(image.isEqual(matchesImage)) {
             //   matchesCountLbl.frame = CGRect.init(x: x  - (smallBtnSize.width / 2), y: 0, width: 13, height: 13)
                likesCountLbl.cornerRadius = 6.5
                likesCountLbl.clipsToBounds = true
                likesCountLbl.frame = CGRect.init(x: x + smallBtnSize.width - 15, y: 0, width: 15, height: 13)
                likesCountLbl.backgroundColor = .white
                likesCountLbl.textColor = .red
                likesCountLbl.text = "0"
                likesCountLbl.textAlignment = .center
                likesCountLbl.isHidden = true
                likesCountLbl.font = UIFont.systemFont(ofSize: 11)
                leftView.addSubview(likesCountLbl)
            }
            x += CGFloat(smallBtnSize.width + BUTTONS_SPACING)
        }
        self.setLeftBarView(leftView:leftView, width:CGFloat(x))
    }
    
    func likesCount(count:Int) {
        likesCountLbl.isHidden = (count == 0) ? true : false
        likesCountLbl.text = count.string
        
        let size = (count.string as NSString).size(withAttributes: [NSAttributedString.Key.font:likesCountLbl.font])
        likesCountLbl.frame = CGRect.init(x: likesCountLbl.frame.origin.x, y: 0, width: size.width + 6.0, height: likesCountLbl.frame.height)
    }
    
    private func setLeftBarView(leftView:UIView, width:CGFloat) {
        let rect = CGRect(x: 0, y: 0, width: width, height: smallBtnSize.height)
        leftView.frame = rect
        let leftBarButton = UIBarButtonItem(customView: leftView)
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    /**********************************************/
    
    /************ SET RIGHT BUTTONS *******************/
    
    private func setRightBarBtns(images:[UIImage]) {
        
        let viewWidth = (CGFloat(images.count) * smallBtnSize.width) + (CGFloat(images.count - 1) * BUTTONS_SPACING)
        let rightView = UIView()
        var x:CGFloat = viewWidth - smallBtnSize.width
        var tag = 0
        
        for image in images {
            let btn = self.createButton(withImage: image,xPosition:x, side: .right)
            tag += 1
            btn.tag = tag
            rightView.addSubview(btn)
            
            
            let matchesImage = UIImage.init(named: "Matches")
            if(image.isEqual(matchesImage)) {
                //   matchesCountLbl.frame = CGRect.init(x: x  - (smallBtnSize.width / 2), y: 0, width: 13, height: 13)
                matchesCountLbl.cornerRadius = 6.5
                matchesCountLbl.clipsToBounds = true
                matchesCountLbl.frame = CGRect.init(x: x + smallBtnSize.width - 15, y: 0, width: 15, height: 13)
                matchesCountLbl.backgroundColor = .white
                matchesCountLbl.textColor = .red
                matchesCountLbl.text = "0"
                matchesCountLbl.textAlignment = .center
                matchesCountLbl.isHidden = true
                matchesCountLbl.font = UIFont.systemFont(ofSize: 11)
                rightView.addSubview(matchesCountLbl)
            }
            
            x -= CGFloat(smallBtnSize.width + BUTTONS_SPACING)
            if (image.size.height < 5) {//profile
                btn.layer.borderWidth = 2
                btn.layer.borderColor = UIColor.white.cgColor
                btn.cornerRadius = btn.frame.size.height / 2.0
                btn.clipsToBounds = true
                btn.sd_imageIndicator = SDWebImageActivityIndicator.white
                print(AppSettings.profilePicUrl)
                btn.sd_setImage(with: URL(string:AppSettings.profilePicUrl), for: .normal, completed: nil)
                btn.backgroundColor = .gray
            }
        }
        self.setRightBarView(rightView:rightView, width:viewWidth)
    }
    
    func matchesCount(count:Int) {
        matchesCountLbl.isHidden = (count == 0) ? true : false
        matchesCountLbl.text = count.string
        
        let size = (count.string as NSString).size(withAttributes: [NSAttributedString.Key.font:matchesCountLbl.font])
        matchesCountLbl.frame = CGRect.init(x: matchesCountLbl.frame.origin.x, y: 0, width: size.width + 6.0, height: matchesCountLbl.frame.height)
    }
    
    private func setRightBarView(rightView:UIView, width:CGFloat) {
        let rect = CGRect(x: 0, y: 0, width: width, height: smallBtnSize.height)
        rightView.frame = rect
        let rightBarBtn = UIBarButtonItem(customView: rightView)
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    /**********************************************/
    
    private func createButton(withImage:UIImage, xPosition:CGFloat, side:BarButtonSide) -> UIButton {
        
        let rect = CGRect(x: xPosition, y: 0, width: smallBtnSize.width, height: smallBtnSize.height)
        let btn = UIButton.init(frame: rect)
        btn.setImage(withImage, for: .normal)
        
        if side == .left {
            
            btn.addTarget(self, action: #selector(leftBarBtnClicked(sender:)), for: .touchUpInside)
        }
        else {
            btn.addTarget(self, action: #selector(rightBarBtnClicked(sender:)), for: .touchUpInside)
        }
        return btn
    }
    
    /********** Bar Buttons Actions ************/
    
    @objc func leftBarBtnClicked(sender:UIButton) {
        switch sender.tag {
        case 1:
            _ = self.navigationController?.popViewController(animated: true)
        default:
            print("Please override the leftBarBtnClicked action")
        }
    }
    
    @objc func rightBarBtnClicked(sender:UIButton) {
        
        switch sender.tag {
        case 1:
            print("ghj")
            //let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileViewController")
            //UIApplication.visibleViewController.navigationController?.pushViewController(vc, animated: true)
        default:
            if let user = Auth.auth().currentUser {
                let vc = ChannelsViewController(currentUser: user)
                UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
            }
        }
    }
    /*******************************************/
}

