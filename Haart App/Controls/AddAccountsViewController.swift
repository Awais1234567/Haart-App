//
//  AddAccounts.swift
//  Haart App
//
//  Created by Stone on 11/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import Quickblox
import FirebaseAuth

class AddAccountsViewController: UIViewController {

    @IBOutlet weak var btnsContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        for view in btnsContainer.subviews {
            if(view.isKind(of: UIButton.self)) {
                view.layer.borderColor = UIColor.red.cgColor
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in btnsContainer.subviews {
            if(view.isKind(of: UIButton.self)) {
                view.layer.cornerRadius = view.frame.size.height / 2.0
            }
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
        self.present(viewController, animated: true, completion: nil)
        if let user = Auth.auth().currentUser{
            quickBloxSignUp(fullName: user.uid, login: user.uid)
        }
    }
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
        self.present(viewController, animated: true, completion: nil)
    }
    private func quickBloxSignUp(fullName: String, login: String) {
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = login
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            
                print("Quickblox signup successful")
            
            }, errorBlock: { [weak self] response in
                
                if response.status == QBResponseStatusCode.validationFailed {
                    // The user with existent login was created earlier
                    //self?.login(fullName: fullName, login: login)
                    return
                }
                //self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
}
