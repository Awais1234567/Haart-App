//
//  VerificationViewController.swift
//  Haart App
//
//  Created by Stone on 11/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
class VerificationViewController: UIViewController {
    @IBOutlet weak var proceedBtn: UIButton!
    var verificationID = ""
    @IBOutlet weak var codeTxtField: HaartTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        proceedBtn.layer.borderColor = UIColor.red.cgColor
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        proceedBtn.layer.cornerRadius = proceedBtn.frame.size.height / 2.0
        
    }
    @IBAction func proceedBtnPressed(_ sender: Any) {
        SVProgressHUD.show()
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                 verificationCode: codeTxtField.text ?? "")
        
        Auth.auth().signIn(with: credential, completion: { (authResult, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                // Handles error
                UIApplication.showMessageWith(error.localizedDescription)
                return
            }
            if (authResult?.user != nil) {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "AddAccountsViewController")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        })
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
