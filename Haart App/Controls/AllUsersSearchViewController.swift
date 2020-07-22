//
//  AllUsersSearchViewController.swift
//  Haart App
//
//  Created by Stone on 15/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

class AllUsersSearchViewController: AbstractControl, UITableViewDelegate, UITableViewDataSource,HaartSearchBarDelegate {
    var currentUserSnapshot:QueryDocumentSnapshot!

 //   let user:User = Auth.auth().currentUser!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: HaartSearchbar!
    @IBOutlet weak var searchImgView: UIImageView!
    var itemsArr = [QueryDocumentSnapshot]()
   // private let db = Firestore.firestore()
    private var appUsersReference: CollectionReference {
        return db.collection("users")
    }
   // private var appUsers = [Any]()
    private var appUsersListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.searchDelegate = self
        //searchBar.items = itemsArr
        searchBar.searchImageView = searchImgView
        tblView.register(UINib(nibName: "FriendCell", bundle: nil), forCellReuseIdentifier: "FriendCell")
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Back")!], rightImage: nil)
      
        
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
                        self.itemsArr.remove(at: i)
                        break
                    }
                }
                var documents = self.itemsArr
                for i in 0..<(documents.count) {
                    if((documents[i].data()["blocked"] as? Array<String> ?? [String]()).contains(user.uid)) {
                        if let index = self.itemsArr.firstIndex(of: documents[i]) {
                            self.itemsArr.remove(at: index)
                        }
                    }
                }
                documents = self.itemsArr
                for i in 0..<(documents.count) {
                    if((self.currentUserSnapshot.data()["blocked"] as? Array<String> ?? [String]()).contains(documents[i].data()["userId"] as! String)) {
                        if let index = self.itemsArr.firstIndex(of: documents[i]) {
                            self.itemsArr.remove(at: index)
                        }
                    }
                }
                self.tblView.reloadData()
            }
            else {
                UIApplication.showMessageWith(error?.localizedDescription ?? "")
            }
            SVProgressHUD.dismiss()
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        appUsersListener?.remove()
//    }
    
    func filteredArr(_ arr: Array<String>) {
       // itemsArr = arr
        tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        cell.configureWith(userDocument: itemsArr[indexPath.row], currentUserSnapshot: currentUserSnapshot, listType: .allUsers)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArr.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

}
