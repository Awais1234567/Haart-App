//
//  FriendsViewController.swift
//  Haart App
//
//  Created by Stone on 28/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import TTSegmentedControl
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

enum ListType {
    case followers
    case followed
    case suggested
    case pending
    case allUsers
}

class FriendsViewController: AbstractControl, UITableViewDelegate, UITableViewDataSource {
    //let user:User = Auth.auth().currentUser!
    var currentUserSnapshot:QueryDocumentSnapshot!
    @IBOutlet weak var searchImageView: UIImageView!
    var listType:ListType = .followers
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var friendsTblView: UITableView!
    let segmentedControl = TTSegmentedControl()
    var itemsArr = [QueryDocumentSnapshot]()
    
    var suggestedArr = [QueryDocumentSnapshot]()
    var followedArr = [QueryDocumentSnapshot]()
    var followerArr = [QueryDocumentSnapshot]()
    var pendingRequestsArr = [QueryDocumentSnapshot]()
    var requestsSentArr = [QueryDocumentSnapshot]()
    var tableArr = [QueryDocumentSnapshot]()
    
//    private let db = Firestore.firestore()
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
        friendsTblView.register(UINib(nibName: "FriendCell", bundle: nil), forCellReuseIdentifier: "FriendCell")

        self.setNavBarButtons(letfImages: [UIImage.init(named: "Search_White")!], rightImage: [UIImage.init(), UIImage.init(named: "Chat")!])
        
        segmentedControl.allowChangeThumbWidth = false
        segmentedControl.frame = CGRect(x: (11/375.0) * UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width - 20, height: 45.0/* * UIScreen.main.bounds.size.height) / 896.0*/)
        segmentedControl.didSelectItemWith = { (index, title) -> () in
            self.searchTxtField.text = ""
            self.view.endEditing(true)
            if (index == 0) //followers
            {
                self.listType = .followers
                self.tableArr = self.followerArr
            }
            else if (index == 1) //followed
            {
                self.listType = .followed
                self.tableArr = self.followedArr
            }
            else if (index == 2) //suggested
            {
                self.listType = .suggested
                self.tableArr = self.suggestedArr
            }
            else if (index == 3) //pending
            {
                self.listType = .pending
                self.tableArr = self.pendingRequestsArr
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
        segmentedControl.itemTitles = ["Followers", "Following", "Suggested", "Pending"]
        searchTxtField.cornerRadius = searchTxtField.frame.size.height / 2.0
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        appUsersReference.getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                self.itemsArr = documents
                let user:User = Auth.auth().currentUser!
                for i in 0..<(documents.count) {
                    if(documents[i].data()["userId"] as! String == user.uid) {
                        self.currentUserSnapshot = documents[i]
                        AppSettings.currentUserSnapshot = self.currentUserSnapshot
                        self.itemsArr.remove(at: i)
                        break
                    }
                }
                self.filterArrToGroup()
                self.friendsTblView.reloadData()
            }
            else {
                UIApplication.showMessageWith(error?.localizedDescription ?? "")
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func filterArrToGroup() {
        suggestedArr.removeAll()
        pendingRequestsArr.removeAll()
        followedArr.removeAll()
        followerArr.removeAll()
        requestsSentArr.removeAll()
        let myLikedArr = currentUserSnapshot.data()["liked"] as? Array<String> ?? Array<String>()
        for item in itemsArr {
            let otherUserLikedArr = item.data()["liked"] as? Array<String> ?? Array<String>()
            let commonLiked = myLikedArr.filter(otherUserLikedArr.contains)
            if((self.currentUserSnapshot.data()["blocked"] as? Array<String> ?? [String]()).contains(item.data()["userId"] as! String)) {
                continue
            }
            else if((item.data()["blocked"] as? Array<String> ?? [String]()).contains(user.uid)) {
                continue
            }
            
            if((currentUserSnapshot.data()["followedBy"] as? Array<String> ?? Array<String>()).contains(item.data()["userId"] as! String)) {
                followerArr.append(item)
            }
            if((currentUserSnapshot.data()["requestSent"] as? Array<String> ?? Array<String>()).contains(item.data()["userId"] as! String)) {
                requestsSentArr.append(item)
            }
            
            if ((currentUserSnapshot.data()["pending"] as? Array<String> ?? Array<String>()).contains(item.data()["userId"] as! String)){
                pendingRequestsArr.append(item)
            }
            if ((currentUserSnapshot.data()["followed"] as? Array<String> ?? Array<String>()).contains(item.data()["userId"] as! String)) {
                followedArr.append(item)
            }
            if ((currentUserSnapshot.data()["suggested"] as? Array<String> ?? Array<String>()).contains(item.data()["userId"] as! String)){
                suggestedArr.append(item)
            }
            else if(commonLiked.count > 0) { //if both have common liked then also in suggested
                suggestedArr.append(item)
            }
            
            if(listType == .followed){
                self.tableArr = self.followedArr
            }
            else if(listType == .followers){
                self.tableArr = self.followerArr
            }
            else if(listType == .pending){
                self.tableArr = self.pendingRequestsArr
            }
            else if(listType == .suggested){
                self.tableArr = self.suggestedArr
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(listType == .pending) {
            return 2
        }
         return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(listType == .pending) {
            return section == 0 ? requestsSentArr.count : pendingRequestsArr.count
        }
        return tableArr.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(listType == .pending) {
            return section == 0 ? "Requests Sent" : "Requests Received"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(listType == .pending) {
            if(section == 0) {
                return requestsSentArr.count > 0 ? 40 : 0
            }
            else {
                return pendingRequestsArr.count > 0 ? 40 : 0
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        if(listType == .pending) {
            if(indexPath.section == 0) {
                cell.configureWith(userDocument: requestsSentArr[indexPath.row], currentUserSnapshot: currentUserSnapshot, listType: listType)

            }
            else {
                cell.configureWith(userDocument: pendingRequestsArr[indexPath.row], currentUserSnapshot: currentUserSnapshot, listType: listType)
            }
        }
        else {
            cell.configureWith(userDocument: tableArr[indexPath.row], currentUserSnapshot: currentUserSnapshot, listType: listType)

        }
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
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "AllUsersSearchViewController")
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
