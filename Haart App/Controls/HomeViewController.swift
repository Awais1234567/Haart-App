//
//  HomeViewController.swift
//  Haart App
//
//  Created by Stone on 27/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FAPaginationLayout
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import CoreLocation
class HomeViewController: AbstractControl, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    //    var visibleRow:Int = 0
    //    private let db = Firestore.firestore()
    private var appUsersReference: CollectionReference {
        return db.collection("users")
    }
    var currentUserSnapshot:QueryDocumentSnapshot!
    
    //private var appUsers = [Any]()
    private var appUsersListener: ListenerRegistration?
    //   let user:User = Auth.auth().currentUser!
    
    var itemsArr = Array<QueryDocumentSnapshot>()
    @IBOutlet weak var swipeAbleView: UIImageView!
    @IBOutlet weak var homeCollectionView: UICollectionView!
    let def = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        def.set(user.uid, forKey: "UserID")
        
        homeCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        homeCollectionView.contentInset = UIEdgeInsets(top: 0, left:  0, bottom: 0, right:  0)
      
        homeCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Filter")!, UIImage.init(named: "lover")!], rightImage: [UIImage.init(), UIImage.init(named: "Matches")!])
        
    
        //getAndSetData()
        //                appUsersListener = appUsersReference.addSnapshotListener { querySnapshot, error in
        //                    guard let snapshot = querySnapshot else {
        //                        UIApplication.showMessageWith(error?.localizedDescription ?? "No error")
        //                        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        //                        return
        //                    }
        //                    snapshot.documentChanges.forEach { change in
        //                        self.getAndSetData()
        //                    }
        //                }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //   appUsersListener?.remove()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.getAndSetData()
        //        appUsersListener = appUsersReference.addSnapshotListener { querySnapshot, error in
        //            guard let snapshot = querySnapshot else {
        //                UIApplication.showMessageWith(error?.localizedDescription ?? "No error")
        //                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        //                return
        //            }
        //            snapshot.documentChanges.forEach { change in
        //                self.itemsArr = snapshot.documents
        //                self.homeCollectionView.reloadData()
        //            }
        //        }
    }
    
    func getAndSetData() {
        SVProgressHUD.show()
        appUsersReference.getDocuments { (snapshot, error) in
            
            if let documents = snapshot?.documents {
                let user:User = Auth.auth().currentUser!
                //  self.itemsArr = documents
                self.itemsArr.removeAll()
                
                for i in 0..<(documents.count) {
                    if(documents[i].data()["userId"] as! String == user.uid) {
                        self.currentUserSnapshot = documents[i]
                        AppSettings.currentUserSnapshot = self.currentUserSnapshot
                        self.likesCount(count:(self.currentUserSnapshot.data()["unreadLikesCount"] as? Int ?? 0) + (self.currentUserSnapshot.data()["unreadSuperLikesCount"] as? Int ?? 0))
                        self.matchesCount(count:self.currentUserSnapshot.data()["unreadMatchesCount"] as? Int ?? 0)
                        let currentUserLocation = CLLocation.init(latitude: self.currentUserSnapshot.data()["lat"] as? CLLocationDegrees ?? 0, longitude: self.currentUserSnapshot.data()["lng"] as? CLLocationDegrees ?? 0)
                        if(currentUserLocation.coordinate.latitude == 0 && currentUserLocation.coordinate.longitude == 0) {
                            UIApplication.showMessageWith("Please add your location first, to see users in your or selected area.")
                        }
                        
                        break
                    }
                }
                
                for i in 0..<(documents.count) {
                    
                    //  print(documents[i].data())
                    if(documents[i].data()["userId"] as! String == user.uid) {
                    }
                    else if((documents[i].data()["blocked"] as? Array<String> ?? [String]()).contains(user.uid)) {
                        //do not show
                    }
                    else if((self.currentUserSnapshot.data()["blocked"] as? Array<String> ?? [String]()).contains(documents[i].data()["userId"] as! String)) {
                        //do not show
                    }
                    else if((documents[i].data()["liked"] as? Array<String> ?? [String]()).contains(user.uid)) {//if he liked me
                        self.itemsArr.insert(documents[i], at: 0)
                    }
                    else if((documents[i].data()["superLiked"] as? Array<String> ?? [String]()).contains(user.uid)) {//if he super liked me
                        self.itemsArr.insert(documents[i], at: 0)
                    }
                    else if (ApplyFilter.isQualified(currentUserSnapshot: self.currentUserSnapshot, othrerUserSnapshot: documents[i])){
                        self.itemsArr.append(documents[i])
                    }
                }
                
                self.homeCollectionView.reloadData()
            }
            else {
                UIApplication.showMessageWith(error?.localizedDescription ?? "")
            }
            SVProgressHUD.dismiss()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //updateCellsLayout()
    }
    
    
    
    override func leftBarBtnClicked(sender: UIButton) {
        switch sender.tag {
        case 1:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FilterViewController")
            self.present(vc, animated: true, completion: nil)
            print("left")
        case 2:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LikedViewController")
            self.navigationController?.pushViewController(vc, animated: true)      default:
                print("left")
        }
        
    }
    
    
    //        func updateCellsLayout()  {
    //
    //            let centerX = homeCollectionView.contentOffset.x + (homeCollectionView.frame.size.width)/2
    //
    //            for cell in homeCollectionView.visibleCells {
    //                var offsetX = centerX - cell.center.x
    //                if offsetX < 0 {
    //                    offsetX *= -1
    //                }
    //                cell.transform = CGAffineTransform.identity
    //                let offsetPercentage = offsetX / (view.bounds.width * 2.7)
    //                let scaleX = 1-offsetPercentage
    //              //  cell.transform = CGAffineTransform(scaleX: scaleX + 0.13, y: scaleX + 0.023)
    //                cell.transform = CGAffineTransform(scaleX: scaleX + 0.11, y: scaleX + 0.037)
    //
    //            }
    //        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize: CGSize = collectionView.bounds.size
        cellSize.width -= collectionView.contentInset.right * 2
        cellSize.height = collectionView.frame.size.height
        return cellSize
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArr.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(itemsArr.count == 0){
            DispatchQueue.main.async {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.homeCollectionView.bounds.size.width, height: self.homeCollectionView.bounds.size.height))
                  noDataLabel.text          = "Reload"
                  noDataLabel.textColor     = UIColor.black
                  noDataLabel.textAlignment = .center
                 self.homeCollectionView.backgroundView  = noDataLabel
            }
        }
        let cell : HomeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath as IndexPath) as! HomeCollectionViewCell
        cell.indexPath = indexPath
        cell.currentUserDocument = currentUserSnapshot
        cell.setData(userDocument: itemsArr[indexPath.row])
        return cell
    
    }
    
    @objc override func rightBarBtnClicked(sender:UIButton) {
        switch sender.tag {
        case 1:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
            self.present(viewController, animated: true, completion: nil)
            
            print("clicked")
        default:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MatchesViewController")
            self.navigationController?.pushViewController(vc, animated: true)      
        }
        
    }
    //
}



