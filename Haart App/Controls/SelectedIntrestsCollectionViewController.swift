//
//  SelectedIntrestsCollectionViewController.swift
//  Haart App
//
//  Created by Stone on 20/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SelectedIntrestsCollectionViewController: UICollectionViewController,SelectedIntrestCellDelegate, UICollectionViewDelegateFlowLayout {
    var cellHeight = 51
    var itemsArr = Array<String>()
    var selectedItemsKey = ""
    var userDocument:QueryDocumentSnapshot? {
        didSet {
            itemsArr = userDocument?.data()[selectedItemsKey] as? [String] ?? Array<String>()
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "SelectedIntrestCell", bundle: nil), forCellWithReuseIdentifier: "SelectedIntrestCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layer.cornerRadius =  self.view.frame.size.height / 1.5
        self.view.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func removedItemAt(_ row: Int) {
        
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(itemsArr.count)
       return itemsArr.count
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell : SelectedIntrestCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedIntrestCell", for: indexPath as IndexPath) as! SelectedIntrestCell
            cell.txtLbl.text = itemsArr[indexPath.row]
            cell.delegate = self
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = itemsArr[indexPath.row]
        print(CGSize.init(width: Int(((text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])).width + 30), height: cellHeight))
        
        return CGSize.init(width: Int(((text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])).width + 30), height: cellHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
    }
   
}
