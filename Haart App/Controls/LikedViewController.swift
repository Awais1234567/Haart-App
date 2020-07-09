//
//  LikedViewController.swift
//  Haart App
//
//  Created by Stone on 14/04/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import TTSegmentedControl
import FirebaseFirestore
import SVProgressHUD

import FirebaseAuth
enum ListLikeType {
    case liked
    case superLiked
}
class LikedViewController: AbstractControl, UITableViewDelegate, UITableViewDataSource {
    var listType:ListLikeType = .liked
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var friendsTblView: UITableView!
    let segmentedControl = TTSegmentedControl()
    var itemsArr = [QueryDocumentSnapshot]()
    var tableViewArr = [QueryDocumentSnapshot]()
    var likedArr = [QueryDocumentSnapshot]()
    var superLikedArr = [QueryDocumentSnapshot]()
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
            self.searchTxtField.text = ""
            self.view.endEditing(true)
            if (index == 0) //followers
            {
                self.listType = .liked
                self.tableViewArr = self.likedArr
            }
            else if (index == 1) //followed
            {
                self.listType = .superLiked
                self.tableViewArr = self.superLikedArr
            }
            print("Selected item \(index)")
            self.friendsTblView.reloadData()
        }
        
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
        segmentedControl.itemTitles = ["Liked", "Super Liked"]
        searchTxtField.cornerRadius = searchTxtField.frame.size.height / 2.0
        if(self.listType == .liked) {
            self.segmentedControl.selectItemAt(index: 0)
        }
        else if(self.listType == .superLiked){
            self.segmentedControl.selectItemAt(index: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        likedArr.removeAll()
        superLikedArr.removeAll()
        SVProgressHUD.show()
        appUsersReference.getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                self.itemsArr = documents
                let user:User = Auth.auth().currentUser!
                for i in 0..<(documents.count) {
                    if(documents[i].data()["userId"] as! String == user.uid) {
                        self.currentUserSnapshot = documents[i]
                        self.currentUserSnapshot.reference.updateData(["unreadLikesCount":0, "unreadSuperLikesCount":0], completion: nil)
                        
                        let unreadLikesCount = documents[i].data()["unreadLikesCount"] as? Int ?? 0
                        let unreadSuperLikesCount = documents[i].data()["unreadSuperLikesCount"] as? Int ?? 0
                        self.segmentedControl.changeTitle(unreadLikesCount == 0 ? "Liked" : "Liked \(unreadLikesCount)", atIndex: 0)
                        self.segmentedControl.changeTitle(unreadSuperLikesCount == 0 ? "Super Liked" : "Super Liked \(unreadSuperLikesCount)", atIndex: 1)
                        self.itemsArr.remove(at: i)
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
                    else if ((self.currentUserSnapshot.data()["superLiked"] as? [String] ?? [String]()).contains(documents[i].data()["userId"] as! String) && (documents[i].data()["superLiked"] as? [String] ?? [String]()).contains(user.uid)) {
                        //super match
                        //do not show
                    }
                    else if((self.currentUserSnapshot.data()["liked"] as? [String] ?? [String]()).contains(documents[i].data()["userId"] as! String) && (documents[i].data()["liked"] as? [String] ?? [String]()).contains(user.uid)) {
                        //match
                        //do not show
                    }
                    else if (/*(self.currentUserSnapshot.data()["superLiked"] as? [String] ?? [String]()).contains(documents[i].data()["userId"] as! String) ||*/ (documents[i].data()["superLiked"] as? [String] ?? [String]()).contains(user.uid)) {
                        self.superLikedArr.append(documents[i])
                    }
                    else if(/*(self.currentUserSnapshot.data()["liked"] as? [String] ?? [String]()).contains(documents[i].data()["userId"] as! String) ||*/ (documents[i].data()["liked"] as? [String] ?? [String]()).contains(user.uid)) {
                        self.likedArr.append(documents[i])
                    }
                }

                if(self.listType == .liked) {
                    self.tableViewArr = self.likedArr
                }
                else if(self.listType == .superLiked){
                    self.tableViewArr = self.superLikedArr
                }
                
                self.friendsTblView.reloadData()
//                var documents = self.itemsArr
//                for i in 0..<(documents.count) {
//                    if((documents[i].data()["blocked"] as? Array<String> ?? [String]()).contains(user.uid)) {
//                        if let index = self.itemsArr.firstIndex(of: documents[i]) {
//                            self.itemsArr.remove(at: index)
//                        }
//                    }
//                }
//                documents = self.itemsArr
//                for i in 0..<(documents.count) {
//                    if((self.currentUserSnapshot.data()["blocked"] as? Array<String> ?? [String]()).contains(documents[i].data()["userId"] as! String)) {
//                        if let index = self.itemsArr.firstIndex(of: documents[i]) {
//                            self.itemsArr.remove(at: index)
//                        }
//                    }
//                }
//                self.filterArrToGroup()
 //               self.friendsTblView.reloadData()
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
    
//    func filterArrToGroup() {
//        likedArr.removeAll()
//        superLikedArr.removeAll()
//
//        for item in itemsArr {
//            if ((currentUserSnapshot.data()["superLiked"] as? [String] ?? [String]()).contains(item.data()["userId"] as! String) || (item.data()["superLiked"] as? [String] ?? [String]()).contains(user.uid)){
//                superLikedArr.append(item)
//            }
//            else if((currentUserSnapshot.data()["liked"] as? [String] ?? [String]()).contains(item.data()["userId"] as! String) || (item.data()["liked"] as? [String] ?? [String]()).contains(user.uid)) {
//                likedArr.append(item)
//            }
//
//            if(listType == .liked) {
//                self.tableViewArr = self.likedArr
//            }
//            else if(listType == .superLiked){
//                self.tableViewArr = self.superLikedArr
//            }
//
//        }
//    }
    
    
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
