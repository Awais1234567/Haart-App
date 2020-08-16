//
//  SearchPopUp.swift
//  Haart App
//
//  Created by OBS on 15/08/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation



import SVProgressHUD
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import UIKit
protocol SearchPopUpViewControllerDelegate: class {
    func didChangeValueForIntrests()
}

class SearchPopUp: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
    let db = Firestore.firestore()
    var userReference: CollectionReference {
        return db.collection("users")
    }
    
    weak var delegate: SearchPopUpViewControllerDelegate?
    var userDocument:QueryDocumentSnapshot?
    
    
    
    @IBOutlet weak var searchTblView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchMovies : Bool = false
    var searchBooks : Bool = false
    var selectedItemsArr = NSMutableArray.init()
    var sender = UIButton.init()
    var currentSelectedList:SelectedIntrestsCollectionViewController!

    var itemsArr = Array<String>()
    var arrKey = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
      
    }
    
    
    func filteredArr(_ arr: Array<String>) {
        itemsArr = arr
        searchTblView.reloadData()
    }
    
    func initializeWith(items: Array<String>, sender:UIButton, arrKey:String) {
      
          self.sender = sender
          self.arrKey = arrKey
          itemsArr = items
          searchTblView.reloadData()
          selectedItemsArr = NSMutableArray.init(array: userDocument?.data()[arrKey] as? NSArray ?? NSArray())
          
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.arrKey.count == 0) { //can not select multiple items (selecting own gender)
            self.sender.setTitle(itemsArr[indexPath.row], for: .normal)
            UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
            return
        }
        
        let selectedItem = itemsArr[indexPath.row]
        
        if(selectedItemsArr.contains(selectedItem)) {
            selectedItemsArr.remove(selectedItem)
        }
        else {
            selectedItemsArr.add(selectedItem)
        }
        searchTblView.reloadData()
        delegate?.didChangeValueForIntrests()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell", for: indexPath) as! InterestsCell
        cell.textLbl.text = itemsArr[indexPath.row]
        let currentItem = itemsArr[indexPath.row]
        //let selectedArr1 = (UserDefaults.standard.object(forKey: arrKey) as? NSArray) ?? NSArray()
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
        
        if (currentSelectedList != nil) {
            currentSelectedList.collectionView.reloadData()
            //UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    func fetchMovies(){
        
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        UIApplication.visibleViewController.dismiss(animated: true, completion: nil)
    }
    
}


