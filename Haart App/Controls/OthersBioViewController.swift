//
//  OthersBioViewController.swift
//  Haart App
//
//  Created by Stone on 05/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SVProgressHUD
import RangeSeekSlider
import SDWebImage
import CoreLocation
import FirebaseFirestore
class OthersBioViewController: InterestPopUpValues {
    
    var currentUserDocument:QueryDocumentSnapshot?
    @IBOutlet weak var currentRelationshipView: UIView!
    @IBOutlet weak var distance1Lbl: UILabel!
    @IBOutlet weak var incomeLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var alcohalView: UIView!
    @IBOutlet weak var workoutView: UIView!
    @IBOutlet weak var foodView: UIView!
    @IBOutlet weak var smookingView: UIView!
    @IBOutlet weak var kidsView: UIView!
    @IBOutlet weak var relationshipView: UIView!
    @IBOutlet weak var starSignView: UIView!
    @IBOutlet weak var educationLevelView: UIView!
    @IBOutlet weak var raceView: UIView!
    @IBOutlet weak var religionView: UIView!
    @IBOutlet weak var bodyTypeView: UIView!
    @IBOutlet weak var eyesColorView: UIView!
    @IBOutlet weak var interestedInView: UIView!
    
    @IBOutlet weak var hobbiesView: UIView!
    
    @IBOutlet weak var moviesView: UIView!
    
    @IBOutlet weak var booksView: UIView!
    @IBOutlet weak var tvShowsView: UIView!
    
    @IBOutlet weak var collegeView: UIView!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var professionView: UIView!
    @IBOutlet weak var incomeSelector: RangeSeekSlider!
    @IBOutlet weak var heightSelector: RangeSeekSlider!
    // var income = Array<String>()
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    //@IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    var workoutSelectedList:SelectedIntrestsCollectionViewController!
    var smokingSelectedList:SelectedIntrestsCollectionViewController!
    var alchohalSelectedList:SelectedIntrestsCollectionViewController!
    var hobbiesSelectedList:SelectedIntrestsCollectionViewController!
    var moviesSelectedList:SelectedIntrestsCollectionViewController!
    var tvShowsSelectedList:SelectedIntrestsCollectionViewController!
    var booksSelectedList:SelectedIntrestsCollectionViewController!
    var collegeSelectedList:SelectedIntrestsCollectionViewController!
    var highSchoolSelectedList:SelectedIntrestsCollectionViewController!
    var dietrySelectedList:SelectedIntrestsCollectionViewController!
    var kidsSelectedList:SelectedIntrestsCollectionViewController!
    var educationSelectedList:SelectedIntrestsCollectionViewController!
    var starSignSelectedList:SelectedIntrestsCollectionViewController!
    var genderSelectedList:SelectedIntrestsCollectionViewController!
    var hairColorSelectedList:SelectedIntrestsCollectionViewController!
    var bodyTypeSelectedList:SelectedIntrestsCollectionViewController!
    var ethnicitySelectedList:SelectedIntrestsCollectionViewController!
    var religionSelectedList:SelectedIntrestsCollectionViewController!
    var professionSelectedList:SelectedIntrestsCollectionViewController!
    var eyeColorSelectedList:SelectedIntrestsCollectionViewController!
    var relationshipSelectedList:SelectedIntrestsCollectionViewController!
    var currrentRelationshipSelectedList:SelectedIntrestsCollectionViewController!
    
    
    
    var userId = ""
    
    var numberFormatter: NumberFormatter = {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.numberStyle = .decimal
        formatter.maximumSignificantDigits = 2
        formatter.decimalSeparator = "'"
        formatter.minimumFractionDigits = 1
        formatter.minimumSignificantDigits = 1
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Filter")!, UIImage.init(named: "Matches")!], rightImage: [UIImage.init(), UIImage.init(named: "Matches")!])
        setSelectedIntrestsViews()
        ageLbl.layer.borderColor = UIColor.red.cgColor
        heightLbl.layer.borderColor = UIColor.red.cgColor
        distanceLbl.layer.borderColor = UIColor.red.cgColor
        incomeLbl.layer.borderColor = UIColor.red.cgColor
        ageLbl.isHidden = true
        heightLbl.isHidden = true
        distanceLbl.isHidden = true
        incomeLbl.isHidden = true
    }
    
    func layout() -> UICollectionViewFlowLayout {
        let  layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width:100, height:30)
        return layout
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    func getData() {
        SVProgressHUD.show()
        let ref = db.collection("users").whereField("userId", isEqualTo: userId)
        ref.getDocuments { (snapshot, error) in
            SVProgressHUD.dismiss()
            if(snapshot?.documents.count == 0) {
            }
            else {
                self.userDocument = snapshot?.documents[0]
                if let imgsArr = (self.userDocument?.data()["bioPics"] as? [String]) {
                    if(imgsArr.count > 0) {
                        self.profileImgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                        self.profileImgView.sd_setImage(with: URL(string:imgsArr[0]), placeholderImage: nil)
                    }
                }
                
                //calculate distance
                let otherUserLocation = CLLocation.init(latitude: self.userDocument?.data()["lat"] as? CLLocationDegrees ?? 0, longitude: self.userDocument?.data()["lng"] as? CLLocationDegrees ?? 0)
                let currentUserLocation = CLLocation.init(latitude: self.currentUserDocument?.data()["lat"] as? CLLocationDegrees ?? 0, longitude: self.currentUserDocument?.data()["lng"] as? CLLocationDegrees ?? 0)
                let distance = CGFloat((currentUserLocation.distance(from: otherUserLocation)) / 1600)
                let text = "\(String(format: "%.2f", distance)) mi away"
                self.distanceLbl.text = text
                self.distance1Lbl.text = text
                
                
                self.nameLbl.text = self.userDocument?.data()["fullName"] as? String ?? ""
                self.bioLbl.text = self.userDocument?.data()["bio"] as? String ?? ""
                let height = self.userDocument?.data()["height"] as? CGFloat ?? 0
                self.addressLbl.text = self.userDocument?.data()["address"] as? String ?? ""
                self.heightLbl.text = height > 0 ? self.numberFormatter.string(from: height as NSNumber)  : ""
                
                self.workoutSelectedList.userDocument = self.userDocument //calling didset
                self.smokingSelectedList.userDocument = self.userDocument
                self.alchohalSelectedList.userDocument = self.userDocument
                self.hobbiesSelectedList.userDocument = self.userDocument
                self.moviesSelectedList.userDocument = self.userDocument
                self.booksSelectedList.userDocument = self.userDocument
                self.tvShowsSelectedList.userDocument = self.userDocument
                self.collegeSelectedList.userDocument = self.userDocument
                self.currrentRelationshipSelectedList.userDocument = self.userDocument
                self.dietrySelectedList.userDocument = self.userDocument
                self.kidsSelectedList.userDocument = self.userDocument
                self.educationSelectedList.userDocument = self.userDocument
                self.starSignSelectedList.userDocument = self.userDocument
                self.genderSelectedList.userDocument = self.userDocument
                //   self.hairColorSelectedList.userDocument = self.userDocument
                self.bodyTypeSelectedList.userDocument = self.userDocument
                self.ethnicitySelectedList.userDocument = self.userDocument
                self.religionSelectedList.userDocument = self.userDocument
                self.professionSelectedList.userDocument = self.userDocument
                self.eyeColorSelectedList.userDocument = self.userDocument
                self.relationshipSelectedList.userDocument = self.userDocument
                
                
                
                if let dob = self.userDocument?.data()["dob"] as? String {
                    if(dob.count > 0) {
                        self.ageLbl.text = (dob.getAgeFromDOB().0.string)
                    }
                }
                else {
                    self.ageLbl.text = ""
                }
                
                let minIncome = Int(ceilf((Float(self.userDocument?.data()["incomeMin"] as? CGFloat ?? 0))))
                let maxIncome = Int(ceilf((Float(self.userDocument?.data()["incomeMax"] as? CGFloat ?? 0))))
                
                let minIncomeStr = minIncome == 1000 ? "$1M" : "$\(minIncome)K"
                let maxIncomeStr = maxIncome == 1000 ? "$1M" : "$\(maxIncome)K"
                self.incomeLbl.text = "\(minIncomeStr) - \(maxIncomeStr)"
                
                self.ageLbl.isHidden = self.ageLbl.text?.count == 0
                self.heightLbl.isHidden = self.heightLbl.text?.count == 0
                self.distanceLbl.isHidden = self.distanceLbl.text?.count == 0
                self.incomeLbl.isHidden = self.incomeLbl.text?.count == 0
            }
        }
    }
    
    
    func setSelectedIntrestsViews() {
        
        currrentRelationshipSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: currrentRelationshipSelectedList, inView: currentRelationshipView, selectedItemsKey: kCurrentReleationshipKey)
        
        professionSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: professionSelectedList, inView: professionView, selectedItemsKey: kProfessionKey)
        
        relationshipSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: relationshipSelectedList, inView: relationshipView, selectedItemsKey: kReleationshipKey)
        
        workoutSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: workoutSelectedList, inView: workoutView, selectedItemsKey: kWorkout)
        
        smokingSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: smokingSelectedList, inView: smookingView, selectedItemsKey: kSmoking)
        
        alchohalSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: alchohalSelectedList, inView: alcohalView, selectedItemsKey: kAlchohal)
        
        hobbiesSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: hobbiesSelectedList, inView: hobbiesView, selectedItemsKey: kHobbies)
        moviesSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: moviesSelectedList, inView: moviesView, selectedItemsKey: kMovies)
        
        booksSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: booksSelectedList, inView: booksView, selectedItemsKey: kBooks)
        
        tvShowsSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: tvShowsSelectedList, inView: tvShowsView, selectedItemsKey: kTvShows)
        
        collegeSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: collegeSelectedList, inView: collegeView, selectedItemsKey: kCollege)
        
        dietrySelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: dietrySelectedList, inView: foodView, selectedItemsKey: kDietryPreferences)
        
        kidsSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: kidsSelectedList, inView: kidsView, selectedItemsKey: kKids)
        
        educationSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: educationSelectedList, inView: educationLevelView, selectedItemsKey: kEducationLevelKey)
        
        
        starSignSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: starSignSelectedList, inView: starSignView, selectedItemsKey: kStarSignKey)
        
        genderSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: genderSelectedList, inView: interestedInView, selectedItemsKey: kGenderKey)
        
        //  hairColorSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        //  self.setSelectedIntrestsView(subVc: hairColorSelectedList, inView: , selectedItemsKey: kHairColorsKey)
        //
        bodyTypeSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: bodyTypeSelectedList, inView: bodyTypeView, selectedItemsKey: kBodyTypeKey)
        
        ethnicitySelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: ethnicitySelectedList, inView: raceView, selectedItemsKey: kEthnicityKey)
        
        religionSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: religionSelectedList, inView: religionView, selectedItemsKey: kReligionKey)
        
        
        eyeColorSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: eyeColorSelectedList, inView: eyesColorView, selectedItemsKey: kEyeColorsKey)
        
    }
    
    func setSelectedIntrestsView(subVc:SelectedIntrestsCollectionViewController,inView:UIView, selectedItemsKey:String) {
        subVc.collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        
        subVc.selectedItemsKey = selectedItemsKey
        //        if let arr = (UserDefaults.standard.object(forKey: selectedItemsKey) as? [String]) {
        //            subVc.itemsArr = arr
        //        }
        self.addChild(subVc)
        inView.addSubview(subVc.view)
        inView.addVisualConstraints(["H:|[subVc]|", "V:|-2-[subVc]-2-|",], subviews: ["subVc":subVc.view])
        subVc.didMove(toParent: self)
        subVc.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    override func leftBarBtnClicked(sender: UIButton) {
        switch sender.tag {
        case 1:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FilterViewController")
            self.present(vc, animated: true, completion: nil)
            break
        case 2:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LikedViewController")
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default: break
            
        }
        
    }
    
    @objc override func rightBarBtnClicked(sender:UIButton) {
        switch sender.tag {
        case 1:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
            self.present(viewController, animated: true, completion: nil)
            print("clicked")
            break
        default:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MatchesViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FeedControl")
        UIApplication.visibleViewController.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        close()
    }
    
    func close() {
        if let nv = self.navigationController {
            nv.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func blockBtnPressed(_ sender: Any) {
        SVProgressHUD.show()
        //  let ref = db.collection("users").whereField("userId", isEqualTo: user.uid)
        //  ref.getDocuments { (snapshot, error) in
        //    let document = snapshot?.documents[0]
        var blockedArr = currentUserDocument?.data()["blocked"] as? [String] ?? Array<String>()
        //        var followedArr = currentUserDocument?.data()["followed"] as? [String] ?? Array<String>()
        //        for i in 0..<(followedArr.count) {
        //            if(followedArr[i] == userId) {
        //                followedArr.remove(at: i)
        //                break
        //            }
        //        }
        if(!blockedArr.contains(userId)) {
            blockedArr.append(userId)
        }
        
        currentUserDocument?.reference.updateData(["blocked":blockedArr], completion: { (error) in
            SVProgressHUD.dismiss()
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                self.close()
            }
        })
        // }
    }
    
}


