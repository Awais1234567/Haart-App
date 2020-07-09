//
//  SignUpViewController.swift
//  Haart App
//
//  Created by Stone on 25/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import UserNotifications
class SignUpViewController: UIViewController {
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var agreementLbl: UILabel!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var agreementImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // do {try Auth.auth().signOut()} catch{}
        // Do any additional setup after loading the view.
        phoneBtn.backgroundColor = .red
        setAgreementText()
        setHelpText()
        agreementImgView.layer.borderColor = UIColor.gray.cgColor
        agreementImgView.layer.borderWidth = 2
        agreementImgView.layer.cornerRadius = 3
        
        let btnHeight = (65 / 896.0) * UIScreen.main.bounds.size.height
        emailBtn.cornerRadius = btnHeight / 2.0
        phoneBtn.cornerRadius = btnHeight / 2.0
        phoneBtn.setShadow(shadowRadius: 13, width: 2, height: 8, opacity: 0.4, color: .red)
        emailBtn.setShadow(shadowRadius: 5, width: 2, height: 2, opacity: 0.2, color: .gray)
        registerForPushNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    
    
    func setHelpText() {
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributedString = NSMutableAttributedString(string:"Need Help", attributes:attrs)
        
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributedString1 = NSMutableAttributedString(string:" Signing Up / Logging In", attributes:attrs2)
        attributedString.append(attributedString1)
        helpBtn.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setAgreementText() {
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.gray]
        let attributedString = NSMutableAttributedString(string:"By creating an account or login Agreeing to our ", attributes:attrs)
        
        let termAtt = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.underlineStyle:1] as [NSAttributedString.Key : Any]
        let attributedString1 = NSMutableAttributedString(string:"Term ", attributes:termAtt)
        attributedString.append(attributedString1)
        
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.gray]
        let attributedString2 = NSMutableAttributedString(string:"& ", attributes:attrs2)
        attributedString.append(attributedString2)
        
        let policyAtt = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.underlineStyle:1] as [NSAttributedString.Key : Any]
        let attributedString3 = NSMutableAttributedString(string:"Privacy Policy", attributes:policyAtt)
        attributedString.append(attributedString3)
        
        let dotAtt = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let attributedString4 = NSMutableAttributedString(string:".", attributes:dotAtt)
        attributedString.append(attributedString4)
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        
        agreementLbl.attributedText = attributedString
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    @IBAction func agreementBtnPressed(_ sender: Any) {
        let imgSize = agreementImgView.image?.size
        if(imgSize?.height ?? 0 > CGFloat.init(5.0)) {
            agreementImgView.image = UIImage()
        }
        else {
            agreementImgView.image = UIImage.init(named: "Tick")
        }
    }
    
    @IBAction func emailBtnPressed(_ sender: Any) {
        let imgSize = agreementImgView.image?.size
        if(imgSize?.height ?? 0 > CGFloat.init(5.0)) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            viewController.placeholderText = "Email"
            self.present(viewController, animated: true, completion: nil)
        }
        else {
            UIApplication.showMessageWith("Please agree with Terms & Privacy Policy to proceed.")
        }
        
    }
    
    @IBAction func phoneBtnPressed(_ sender: Any) {
        let imgSize = agreementImgView.image?.size
        if(imgSize?.height ?? 0 > CGFloat.init(5.0)) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            viewController.placeholderText = "Phone Number"
            self.present(viewController, animated: true, completion: nil)
        }
        else {
            UIApplication.showMessageWith("Please agree with Terms & Privacy Policy to proceed.")
        }
        
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                granted, error in
                print("Permission granted: \(granted)") // 3
        }
    }
}

