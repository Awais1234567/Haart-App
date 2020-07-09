//
//  SettingsViewController.swift
//  Haart App
//
//  Created by Stone on 05/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import SVProgressHUD
class SettingsViewController: AbstractControl, UITableViewDataSource, UITableViewDelegate {
    
    let accountsArr = ["Facebook", "Sync Contacts", "Instagram", "Twitter", "WhatsApp", "Snapchat", "Spotify","Blocked Accounts"]
    let othersArr = ["Notifications", "Profile", "Dating Profile", "Profile States", "Location"]
    let legalStuffArr = ["Terms of Use", "Privacy Policy","Data Policy","Location Policy"]
    let moreArr = ["About Haart App", "Support Center", "Feedback", "Reset Password", "Delete Account", "Logout"]
    @IBOutlet weak var settingsTblView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTblView.register(UINib(nibName: "SettingsSimpleCell", bundle: nil), forCellReuseIdentifier: "SettingsSimpleCell")
        self.setNavBarButtons(letfImages: [], rightImage: [UIImage.init(), UIImage.init(named: "Chat")!])
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = accountsArr.count
            break
        case 1:
            rows = othersArr.count
            break
        case 2:
            rows = legalStuffArr.count
            break
        case 3:
            rows = moreArr.count
            break
        default:
            rows = 0
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSimpleCell", for: indexPath) as! SettingsSimpleCell
        cell.switch1.isHidden = true
        switch indexPath.section {
        case 0:
            cell.txtLbl.text = accountsArr[indexPath.row]
            if(indexPath.row != 7) {
                cell.switch1.isHidden = false
            }
            break
        case 1:
            cell.txtLbl.text = othersArr[indexPath.row]
            if(indexPath.row == 0 || indexPath.row == 4) {
                cell.switch1.isHidden = false
            }
            break
        case 2:
            cell.txtLbl.text = legalStuffArr[indexPath.row]
            break
        case 3:
            cell.txtLbl.text = moreArr[indexPath.row]
            break
        default:
            cell.txtLbl.text = "Internal Error"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch section {
        case 0:
            title = "Accounts"
            break
        case 1:
            title = "Others"
            break
        case 2:
            title = "Legal Stuff"
            break
        default:
            title = "Tools"
        }
        return title
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 3 && indexPath.row == 5) {
            self.logout()
        }
    }
    
    func logout() {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            if let currentUserDoc = AppSettings.currentUserSnapshot {
                SVProgressHUD.show()
                currentUserDoc.reference.updateData(["fcmToken":""], completion: { (error) in
                    SVProgressHUD.dismiss()
                    if let e = error {
                        UIApplication.showMessageWith(e.localizedDescription)
                        return
                    }
                    do {
                        try Auth.auth().signOut()
                        GIDSignIn.sharedInstance()?.signOut()
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        UserDefaults.standard.set("", forKey: "Email")
                        AppSettings.userName = ""
                        AppSettings.fullName = ""
                        AppSettings.profilePicUrl = ""
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SignUpViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                    } catch {
                        UIApplication.showMessageWith(error.localizedDescription)
                        print("Error signing out: \(error.localizedDescription)")
                    }
                })
            }
        }))
        present(ac, animated: true, completion: nil)
    }
    @objc override func rightBarBtnClicked(sender:UIButton) {
        
        switch sender.tag {
        case 1:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
            self.present(viewController, animated: true, completion: nil)
            
            print("clicked")
        default:
            if let user = Auth.auth().currentUser {
                let vc = ChannelsViewController(currentUser: user)
                UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
            }
        }
        
    }

}
