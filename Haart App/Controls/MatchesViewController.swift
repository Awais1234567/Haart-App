//
//  MatchesViewController.swift
//  Haart App
//
//  Created by Stone on 29/04/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import UIKit
import TTSegmentedControl
import FirebaseFirestore
import SVProgressHUD
import FirebaseAuth
class MatchesViewController: AbstractControl, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var friendsTblView: UITableView!
    let segmentedControl = TTSegmentedControl()
    var tableViewArr = [QueryDocumentSnapshot]()
    var currentUserSnapshot:QueryDocumentSnapshot!
    
    private var appUsersReference: CollectionReference {
        return db.collection("users")
    }
    //  private var appUsers = [Any]()
    private var appUsersListener: ListenerRegistration?
    
    @IBOutlet weak var searchTxtField: HaartSearchbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        searchTxtField.searchImageView = searchImageView
        friendsTblView.register(UINib(nibName: "LIkedCell", bundle: nil), forCellReuseIdentifier: "LIkedCell")
        
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Back")!], rightImage: [UIImage.init(), UIImage.init(named: "Chat")!])
        
        segmentedControl.allowChangeThumbWidth = false
        segmentedControl.frame = CGRect(x: (11/375.0) * UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width - 20, height: 45.0/* * UIScreen.main.bounds.size.height) / 896.0*/)
        segmentedControl.didSelectItemWith = { (index, title) -> () in
           
        }
        segmentContainer.isUserInteractionEnabled = false
        segmentContainer.addSubview(segmentedControl)
        segmentContainer.backgroundColor = UIColor.red
        segmentedControl.defaultTextFont = UIFont.systemFont(ofSize: 15)
        segmentedControl.selectedTextFont = UIFont.systemFont(ofSize: 15)
        segmentedControl.defaultTextColor = UIColor.white
        segmentedControl.padding = CGSize.init(width: 20, height: 10)
        segmentedControl.selectedTextColor = UIColor.black
        segmentedControl.thumbColor = .white
        segmentedControl.useGradient = false
        segmentedControl.containerBackgroundColor = .clear
        segmentedControl.itemTitles = ["Matches"]
        searchTxtField.cornerRadius = searchTxtField.frame.size.height / 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewArr.removeAll()
        SVProgressHUD.show()
        appUsersReference.getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                let user:User = Auth.auth().currentUser!
                for i in 0..<(documents.count) {
                    if(documents[i].data()["userId"] as! String == user.uid) {
                        self.currentUserSnapshot = documents[i]
                        self.currentUserSnapshot.reference.updateData(["unreadMatchesCount":0], completion: nil)
                        break
                    }
                }
                
                for i in 0..<(documents.count) {
                    print(documents[i].data())
                    if(documents[i].data()["userId"] as! String == user.uid) {
                    }
                    else if((documents[i].data()["blocked"] as? Array<String> ?? [String]()).contains(user.uid)) {
                        //do not show
                    }
                    else if((self.currentUserSnapshot.data()["blocked"] as? Array<String> ?? [String]()).contains(documents[i].data()["userId"] as! String)) {
                        //do not show
                    }
                    else if ((self.currentUserSnapshot.data()["superLiked"] as? Array<String> ?? Array<String>()).contains(documents[i].data()["userId"] as! String) && (documents[i].data()["superLiked"] as? Array<String> ?? Array<String>()).contains(user.uid)){
                        self.tableViewArr.append(documents[i])
                    }
                    else if(((self.currentUserSnapshot.data()["liked"] as? Array<String> ?? Array<String>()).contains(documents[i].data()["userId"] as! String) || (self.currentUserSnapshot.data()["superLiked"] as? Array<String> ?? Array<String>()).contains(documents[i].data()["userId"] as! String))
                        &&
                        (((documents[i].data()["liked"] as? Array<String> ?? Array<String>()).contains(user.uid)) || ((documents[i].data()["superLiked"] as? Array<String> ?? Array<String>()).contains(user.uid)))) {
                        self.tableViewArr.append(documents[i])
                    }
                }
                self.friendsTblView.reloadData()
            }
            else {
                UIApplication.showMessageWith(error?.localizedDescription ?? "")
            }
            SVProgressHUD.dismiss()
        }
        self.navigationController?.navigationBar.removeRoundBottom()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.roundBottom()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LIkedCell", for: indexPath) as! LIkedCell
        
        cell.configureWith(userDocument: tableViewArr[indexPath.row], currentUserSnapshot: currentUserSnapshot, listType: .suggested)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
    
    override func leftBarBtnClicked(sender: UIButton) {
        if let nv = self.navigationController {
            if(nv.viewControllers.count == 1) {
                nv.dismiss(animated: true, completion: nil)
            }
            else {
                nv.popViewController(animated: true)
            }
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}
