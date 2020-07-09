//
//  ProfessionsVC.swift
//  Haart App
//
//  Created by Stone on 05/03/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SwiftMessages
import FirebaseFirestore
import SVProgressHUD
import FirebaseAuth
class ProfessionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, HaartSearchBarDelegate {
    let db = Firestore.firestore()
    var userReference: CollectionReference {
        return db.collection("users")
    }
    @IBOutlet weak var professionTxtField: HaartTextField!
    @IBOutlet weak var searchTblView: UITableView!
    @IBOutlet weak var interestsSearchBar: HaartSearchbar!
    @IBOutlet weak var searchBarImgView: UIImageView!
     var userDocument:QueryDocumentSnapshot?
    var sender = UIButton.init()
    var currentSelectedList:SelectedIntrestsCollectionViewController!
    var selectedItemsArr = NSMutableArray.init()
    var itemsArr = Array<String>()
    var arrKey = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interestsSearchBar.searchDelegate = self
        interestsSearchBar.searchImageView = searchBarImgView
    }
    
    func initializeWith(items: Array<String>, sender:UIButton, arrKey:String) {
        self.sender = sender
        self.arrKey = arrKey
        itemsArr = items
        interestsSearchBar.items = items
        selectedItemsArr = NSMutableArray.init(array: userDocument?.data()[arrKey] as? NSArray ?? NSArray())
        searchTblView.reloadData()
    }
    
    func filteredArr(_ arr: Array<String>) {
        itemsArr = arr
        searchTblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.arrKey.count == 0) { //can not select multiple items (selecting own gender)
            self.sender.setTitle(itemsArr[indexPath.row], for: .normal)
            UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
            return
        }
        //  let cell = tableView.cellForRow(at: indexPath) as! InterestsCell
        
        let selectedItem = itemsArr[indexPath.row]
//        let selectedArr1 = (UserDefaults.standard.object(forKey: arrKey) as? NSArray) ?? NSArray()
//        let selectedArr = NSMutableArray.init(array: selectedArr1)
        if(selectedItemsArr.contains(selectedItem)) {
            selectedItemsArr.remove(selectedItem)
        }
        else {
            selectedItemsArr.add(selectedItem)
        }
        itemsArr.remove(at: indexPath.row)
        interestsSearchBar.items = itemsArr
      //  UserDefaults.standard.set(itemsArr, forKey: arrKey)
        searchTblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell", for: indexPath) as! InterestsCell
        cell.textLbl.text = itemsArr[indexPath.row]
        let currentItem = itemsArr[indexPath.row]
       // let selectedArr1 = (UserDefaults.standard.object(forKey: arrKey) as? NSArray) ?? NSArray()
       // let selectedArr = NSMutableArray.init(array: selectedArr1)
        if (self.arrKey.count == 0) { //can not select multiple items (selecting own gender)
            cell.heartImgView.isHidden = true
        }
        
        if(selectedItemsArr.contains(currentItem)) {
            cell.heartImgView.image = UIImage(named: "heartLike")
        }
        else {
            cell.heartImgView.image = UIImage(named: "heartUnlike")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArr.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        self.view.endEditing(true)
        if (self.arrKey.count == 0) { //can not select multiple items (selecting own gender)
            UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
            return
        }
        currentSelectedList.itemsArr = selectedItemsArr as! [String]
        if(self.userDocument == nil) {
            SVProgressHUD.show()
            self.userReference.addDocument(data: ["userId": Auth.auth().currentUser!.uid, arrKey:selectedItemsArr as! [String]]) { error in
                SVProgressHUD.dismiss()
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                else {
                    UIApplication.visibleViewController.dismiss(animated: true, completion: {
                        UIApplication.visibleViewController.viewWillAppear(false) //reload data
                    })
                }
            }
        }else {
            SVProgressHUD.show()
            userDocument?.reference.updateData([arrKey:selectedItemsArr as! [String]], completion: { (error) in
                SVProgressHUD.dismiss()
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                else {
                    UIApplication.visibleViewController.dismiss(animated: true, completion: {
                        UIApplication.visibleViewController.viewWillAppear(false) //reload data
                    })
                }
            })
        }
        
        currentSelectedList.collectionView.reloadData()
            
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
    }
    @IBAction func addBtnPressed(_ sender: Any) {
        if(professionTxtField.text?.count ?? 0 > 0) {
           // let selectedArr1 = (UserDefaults.standard.object(forKey: arrKey) as? NSArray) ?? NSArray()
            if(selectedItemsArr.contains(professionTxtField.text!)) {
                let view = MessageView.viewFromNib(layout: .centeredView)
                view.configureTheme(.error)
                view.configureDropShadow()
                (view.backgroundView as? CornerRoundingView)?.layer.cornerRadius = 10
                view.configureContent(title: "Message", body: "Already Exist.", iconText: "")
                SwiftMessages.show(view: view)
                view.button?.removeFromSuperview()
            }
            else {
               // var tempArr = selectedItemsArr as! [String]
                selectedItemsArr.add(professionTxtField.text ?? "")
                //UserDefaults.standard.set(tempArr, forKey: arrKey)
                itemsArr = selectedItemsArr as! [String]
                interestsSearchBar.items = selectedItemsArr as? Array<String>
                searchTblView.reloadData()
                professionTxtField.text = ""
            }
        }
    }
    
}
