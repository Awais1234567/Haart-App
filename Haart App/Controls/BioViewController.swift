//
//  BioViewController.swift
//  Haart App
//
//  Created by Stone on 02/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SwiftMessages
import RangeSeekSlider
import DateTimePicker
import FirebaseAuth
import FirebaseFirestore
import Firebase
import SVProgressHUD
import CoreLocation
import YPImagePicker
import SDWebImage
import GoogleMaps

class BioViewController: InterestPopUpValues, UIScrollViewDelegate {
    var randomStr:String?
    var shouldFetchImagesArr = true
    var postalCode:String?
    var gmsAddress1: GMSAddress?
    @IBOutlet weak var bioPic2Btn: UIButton!
    @IBOutlet weak var bioPic1Btn: UIButton!
    @IBOutlet weak var bioPic5Btn: UIButton!
    @IBOutlet weak var bioPic3Btn: UIButton!
    @IBOutlet weak var bioPic4Btn: UIButton!
    var bioPicsArr = ["","","","",""]
    private let storage = Storage.storage().reference()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var ownGenderBtn: UIButton!
    @IBOutlet weak var ownGenderView: UIView!
    @IBOutlet weak var dobTxtField: HaartTextField!
    @IBOutlet weak var fullBioBtn: UIButton!
    @IBOutlet weak var bioScrollView: UIScrollView!
    @IBOutlet weak var heightSelector: RangeSeekSlider!
   
    @IBOutlet weak var bioTxtView: HaartTextView!
    @IBOutlet weak var userNameTxtField: HaartTextField!
    @IBOutlet weak var fullNameTxtField: HaartTextField!
    // @IBOutlet weak var distanceSelector: RangeSeekSlider!
    // @IBOutlet weak var ageSelector: RangeSeekSlider!
    
    @IBOutlet weak var incomeSelector: RangeSeekSlider!
    @IBOutlet weak var currentRelationShipView: UIView!
    // @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var intrestedInView: UIView!
    @IBOutlet weak var eyeColorView: UIView!
    @IBOutlet weak var hairColorView: UIView!
    @IBOutlet weak var bodyTypeView: UIView!
    @IBOutlet weak var religionView: UIView!
    @IBOutlet weak var ethinicityView: UIView!
    @IBOutlet weak var professionView: UIView!
    @IBOutlet weak var educationView: UIView!
    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var starSignView: UIView!
    @IBOutlet weak var relationshipView: UIView!
    @IBOutlet weak var kidsView: UIView!
    @IBOutlet weak var dietView: UIView!
    @IBOutlet weak var gymView: UIView!
    @IBOutlet weak var smokingView: UIView!
    @IBOutlet weak var alcohalView: UIView!
    @IBOutlet weak var dobBtn: UIButton!
    @IBOutlet weak var zipCodeTxtField: HaartTextField!
    @IBOutlet weak var aboutYouTxtView: HaartTextView!
    
    var currentRelationshipStatusList:SelectedIntrestsCollectionViewController!
    var workoutSelectedList:SelectedIntrestsCollectionViewController!
    var smokingSelectedList:SelectedIntrestsCollectionViewController!
    var alchohalSelectedList:SelectedIntrestsCollectionViewController!
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
    var intrestedSelectedList:SelectedIntrestsCollectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIApplication.shared.locationManager.delegate = self
//        UIApplication.shared.locationManager.startUpdatingLocation()
        locationManager.startUpdatingLocation()
        bioScrollView.delegate = self
        generateIncomeValues()
        datePickerRange()
        self.datePickerContainer.isHidden = true
        fullNameTxtField.delegate = self
        heightSelector.numberFormatter.numberStyle = .decimal
        heightSelector.numberFormatter.maximumSignificantDigits = 2
        heightSelector.numberFormatter.decimalSeparator = "'"
        heightSelector.numberFormatter.minimumFractionDigits = 1
        heightSelector.numberFormatter.minimumSignificantDigits = 1
        heightSelector.minValue = 3.0
        heightSelector.maxValue = 8.0
        heightSelector.disableRange = true
        heightSelector.handleImage = UIImage.init(named: "heartLike")
        heightSelector.handleDiameter = 22
        
        incomeSelector.numberFormatter.numberStyle = .decimal
        incomeSelector.delegate = self
        incomeSelector.numberFormatter.maximumSignificantDigits = 2
        incomeSelector.numberFormatter.decimalSeparator = "'"
        incomeSelector.numberFormatter.minimumFractionDigits = 1
        incomeSelector.numberFormatter.minimumSignificantDigits = 1
        incomeSelector.disableRange = false
        incomeSelector.handleImage = UIImage.init(named: "heartLike")
        incomeSelector.handleDiameter = 22
        
        //  distanceSelector.numberFormatter.positiveSuffix = " mi"
        //  viewHeightConstraint.constant = 810
        if #available(iOS 11.0, *){
            bioScrollView.contentInsetAdjustmentBehavior = .never
        }
        else {
            automaticallyAdjustsScrollViewInsets = false
        }
        fullBioBtn.layer.borderWidth = 2
        fullBioBtn.layer.borderColor = UIColor.red.cgColor
        bioScrollView.bounces = false
        setSelectedIntrestsViews()
        
        aboutYouTxtView.maxCharacterLimit = 120
        bioTxtView.maxCharacterLimit = 500
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(currentSelectedList != nil){
            currentSelectedList.view.setNeedsLayout()
            currentSelectedList.view.setNeedsDisplay()
        }
        getData()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(currentSelectedList != nil){
            currentSelectedList.view.setNeedsLayout()
            currentSelectedList.view.setNeedsDisplay()
        }
        bioScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 860)
        UIApplication.shared.statusBarView?.backgroundColor = .clear
        
    }
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .red
        self.view.endEditing(true)
    }

    
    func getData() {
        if(self.userDocument == nil) {
            SVProgressHUD.show()
        }
        
        let ref = db.collection("users").whereField("userId", isEqualTo: self.user.uid)
        ref.getDocuments { (snapshot, error) in
           
            if(self.userDocument == nil) {
                SVProgressHUD.dismiss()
            }
            
            if(snapshot?.documents.count == 0) {
                
            }
            else {
                self.userDocument = snapshot?.documents[0]
                self.setData()
            }
            if(self.fullNameTxtField.text?.count ?? 0 == 0) {
                self.showMessageToEnterFullName()
            }
        }
    }
    func setData() {
        AppSettings.currentUserSnapshot = self.userDocument
        self.currentRelationshipStatusList.userDocument = self.userDocument
        self.workoutSelectedList.userDocument = self.userDocument
        self.smokingSelectedList.userDocument = self.userDocument
        self.alchohalSelectedList.userDocument = self.userDocument
        self.dietrySelectedList.userDocument = self.userDocument
        self.kidsSelectedList.userDocument = self.userDocument
        self.educationSelectedList.userDocument = self.userDocument
        self.starSignSelectedList.userDocument = self.userDocument
        self.genderSelectedList.userDocument = self.userDocument
        self.hairColorSelectedList.userDocument = self.userDocument
        self.bodyTypeSelectedList.userDocument = self.userDocument
        self.ethnicitySelectedList.userDocument = self.userDocument
        self.religionSelectedList.userDocument = self.userDocument
        self.professionSelectedList.userDocument = self.userDocument
        self.eyeColorSelectedList.userDocument = self.userDocument
        self.relationshipSelectedList.userDocument = self.userDocument
        self.intrestedSelectedList.userDocument = self.userDocument
     
        if(self.shouldUpdateTxtFieldsAndRangeFromServer == true) {
            fullNameTxtField.text = self.userDocument?.data()["fullName"] as? String
            userNameTxtField.text = self.userDocument?.data()["userName"] as? String
            zipCodeTxtField.text = self.userDocument?.data()["zipCode"] as? String
            dobTxtField.text = self.userDocument?.data()["dob"] as? String
           // zipCodeTxtField.text = self.userDocument?.data()["zipCode"] as? String
            aboutYouTxtView.text = self.userDocument?.data()["aboutYou"] as? String
            aboutYouTxtView.placeholderText = aboutYouTxtView.text.count > 0 ? "" : "Describe Something..."
            aboutYouTxtView.textViewDidChange(aboutYouTxtView)
            bioTxtView.text = self.userDocument?.data()["bio"] as? String
            bioTxtView.textViewDidChange(bioTxtView)
            heightSelector.selectedMaxValue = self.userDocument?.data()["height"] as? CGFloat ?? CGFloat.init(5.0)
            heightSelector.layoutSubviews()
            incomeSelector.selectedMinValue = self.userDocument?.data()["incomeMin"] as? CGFloat ?? CGFloat.init(3.0)
            incomeSelector.selectedMaxValue = self.userDocument?.data()["incomeMax"] as? CGFloat ?? CGFloat.init(8.0)
            incomeSelector.layoutSubviews()
            textFieldDidEndEditing(fullNameTxtField)
        }
        self.shouldUpdateTxtFieldsAndRangeFromServer = true
        if(shouldFetchImagesArr == true) { //do not update agaib and gain because already updated
            bioPicsArr = self.userDocument?.data()["bioPics"] as? [String] ?? ["","","","",""]
        }
        shouldFetchImagesArr = false
        print(bioPicsArr)
        bioPic1Btn.sd_setImage(with: URL.init(string: bioPicsArr[0]), for: .normal, placeholderImage: bioPic1Btn.image(for: .normal), options: .retryFailed, context: nil)
        bioPic2Btn.sd_setImage(with: URL.init(string: bioPicsArr[1]), for: .normal, placeholderImage: bioPic2Btn.image(for: .normal), options: .retryFailed, context: nil)
        bioPic3Btn.sd_setImage(with: URL.init(string: bioPicsArr[2]), for: .normal, placeholderImage: bioPic3Btn.image(for: .normal), options: .retryFailed, context: nil)
        bioPic4Btn.sd_setImage(with: URL.init(string: bioPicsArr[3]), for: .normal, placeholderImage: bioPic4Btn.image(for: .normal), options: .retryFailed, context: nil)
        bioPic5Btn.sd_setImage(with: URL.init(string: bioPicsArr[4]), for: .normal, placeholderImage: bioPic5Btn.image(for: .normal), options: .retryFailed, context: nil)
    }
    
    func saveUser() {
        
        var userData = ["dob":dobTxtField.text ?? "", "zipCode":zipCodeTxtField.text ?? "", "aboutYou":aboutYouTxtView.text ?? "", "bio":bioTxtView.text ?? "", "height":heightSelector.selectedMaxValue, "incomeMin":incomeSelector.selectedMinValue, "incomeMax":incomeSelector.selectedMaxValue] as [String : Any]
      
        if(gmsAddress1 != nil) {
            userData["address"] = "\(gmsAddress1?.locality ?? "")"
            userData["lat"] = gmsAddress1?.coordinate.latitude ?? 0
            userData["lng"] = gmsAddress1?.coordinate.longitude ?? 0
            
            if(((userData["filterZipCode"] as? String) ?? "").count == 0) {
                userData["filterLat"] = gmsAddress1?.coordinate.latitude ?? 0
                userData["filterLng"] = gmsAddress1?.coordinate.longitude ?? 0
                userData["filterZipCode"] = zipCodeTxtField.text ?? ""
            }
        }
               
        userData["bioPics"] = bioPicsArr
        userData["userId"] = self.user.uid
        userData["fullName"] = self.fullNameTxtField.text ?? ""
        userData["userName"] = self.userNameTxtField.text ?? ""
        userData["email"] = UserDefaults.standard.value(forKey: "Email") ?? ""
        userData["fcmToken"] = AppSettings.deviceToken
        AppSettings.profilePicUrl = bioPicsArr[0]
        AppSettings.userName = self.userNameTxtField.text ?? ""
        AppSettings.fullName = self.fullNameTxtField.text ?? ""
        if(self.userDocument == nil) {// new user
                        
            let user = ["id":self.user.uid,"name":fullNameTxtField.text ?? "","picture":bioPicsArr[0]]
        
            let stories = ["id":"ty","last_updated":Int(Date.init().timeIntervalSince1970),"user":user,"snaps_count":0,"snaps":[]] as [String : Any]
            userData["stories"] = stories
            
            userData["filterMinHeight"] = 3.0
            userData["filterMaxHeight"] = 8.0
            userData["filterAgeMin"] = 18.0
            userData["filterAgeMax"] = 100.0
            userData["filterDistanceMin"] = 0.0
            userData["filterDistanceMax"] = 100.0
            userData["filterIncomeMin"] = 0.0
            userData["filterIncomeMax"] = 1000.0
            
            
            let filterKeys = ["fcurrentRelationship",
            "frelationships",
            "fworkout",
            "fsmoking",
            "falchohal",
            "fdietryPreferences",
            "fkids",
            "feducationLevel",
            "fstarSign",
            "fgender",
            "fhairColors",
            "fbodyFigure",
            "fethnicitys",
            "freligion",
            "feyeColors"]
            
            for key in filterKeys {
                userData[key] = ["All"]
            }
                SVProgressHUD.show()
                self.userReference.addDocument(data: userData) { error in
                    SVProgressHUD.dismiss()
                    if let e = error {
                        UIApplication.showMessageWith(e.localizedDescription)
                    }
                    else {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HaartTabViewCotroller") as! UITabBarController
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                    }
                }
            }
            else {
                let document = self.userDocument!
                SVProgressHUD.show()
                document.reference.updateData(userData, completion: { (error) in
                   SVProgressHUD.dismiss()
                    if let e = error {
                        UIApplication.showMessageWith(e.localizedDescription)
                    }
                    else {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HaartTabViewCotroller") as! UITabBarController
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                    }
                })
            }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == fullNameTxtField) {
            if(textField.text?.count ?? 0 > 0) {
                let text = textField.text?.replacingOccurrences(of: " ", with: "_") ?? ""
                if(randomStr == nil) {
                    randomStr = "".randomStringWithLength(len: 8) as String
                }
                if(self.userDocument?.data()["fullName"] as? String != fullNameTxtField.text) {
                    userNameTxtField.text = "@\(text)_\(randomStr!)"
                }
                
                
                ownGenderBtn.isUserInteractionEnabled = true
                dobBtn.isUserInteractionEnabled = true
                aboutYouTxtView.isUserInteractionEnabled = true
             //   zipCodeTxtField.isUserInteractionEnabled = true
                genderSelectedList.view.isUserInteractionEnabled = true
            }
            else {
                userNameTxtField.text = ""
                ownGenderBtn.isUserInteractionEnabled = false
                dobBtn.isUserInteractionEnabled = false
                aboutYouTxtView.isUserInteractionEnabled = false
               // zipCodeTxtField.isUserInteractionEnabled = false
                genderSelectedList.view.isUserInteractionEnabled = false
                bioScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 860)
            }
        }

    }
    
    func layout() -> UICollectionViewFlowLayout {
        let  layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width:100, height:51)
        return layout
    }
    
    
    
    func setCollectionViewGestures() {
        
        intrestedSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(intrestedInBtnPressed(_:))))
        currentRelationshipStatusList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(currentRelationshipBtnPressed(_:))))
        workoutSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(workoutBtnPressed(_:))))
        smokingSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(smokingBtnPressed(_:))))
        alchohalSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(alchohalBtnPressed(_:))))
        dietrySelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(dietBtnPressed(_:))))
        kidsSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(kidsBtnPressed(_:)) ))
        professionSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(proffesionBtnPressed(_:)) ))
       
        educationSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(educationBtnPressed(_:))))
        starSignSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(zoadicBtnPressed(_:))))
        genderSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(ownGenderBtnPressed(_:))))
        hairColorSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hairColorBtnPressed(_:)) ))
        bodyTypeSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTypeBtnPressed(_:)) ))
        ethnicitySelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(raceBtnPressed(_:))))
        religionSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(religionBtnPressed(_:))))
        eyeColorSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(eyeColorBtnPressed(_:))))

        relationshipSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(relationshipBtnPressed(_:))))

    }
    
    func setSelectedIntrestsViews() {
        
        intrestedSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: intrestedSelectedList, inView: intrestedInView, selectedItemsKey: kIntrestedInKey)
        
        currentRelationshipStatusList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: currentRelationshipStatusList, inView: currentRelationShipView, selectedItemsKey: kCurrentReleationshipKey)
        
        relationshipSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: relationshipSelectedList, inView: relationshipView, selectedItemsKey: kReleationshipKey)

        workoutSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: workoutSelectedList, inView: gymView, selectedItemsKey: kWorkout)

        smokingSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: smokingSelectedList, inView: smokingView, selectedItemsKey: kSmoking)

        alchohalSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: alchohalSelectedList, inView: alcohalView, selectedItemsKey: kAlchohal)

        dietrySelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: dietrySelectedList, inView: dietView, selectedItemsKey: kDietryPreferences)

        kidsSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: kidsSelectedList, inView: kidsView, selectedItemsKey: kKids)

       
        educationSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: educationSelectedList, inView: educationView, selectedItemsKey: kEducationLevelKey)

        starSignSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: starSignSelectedList, inView: starSignView, selectedItemsKey: kStarSignKey)

        genderSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        genderSelectedList.view.isUserInteractionEnabled = false
        
        self.setSelectedIntrestsView(subVc: genderSelectedList, inView: ownGenderView, selectedItemsKey: kGenderKey)

        hairColorSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: hairColorSelectedList, inView: hairColorView, selectedItemsKey: kHairColorsKey)
//
        bodyTypeSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: bodyTypeSelectedList, inView: bodyTypeView, selectedItemsKey: kBodyTypeKey)

        ethnicitySelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: ethnicitySelectedList, inView: ethinicityView, selectedItemsKey: kEthnicityKey)

        religionSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
       self.setSelectedIntrestsView(subVc: religionSelectedList, inView: religionView, selectedItemsKey: kReligionKey)
//
        
       
        professionSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: professionSelectedList, inView: professionView, selectedItemsKey: kProfessionKey)

        eyeColorSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: eyeColorSelectedList, inView: eyeColorView, selectedItemsKey: kEyeColorsKey)
        setCollectionViewGestures()
    }
    
    func showMessageToEnterFullName() {
       
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let view = MessageView.viewFromNib(layout: .centeredView)
            view.configureTheme(.error)
            view.configureDropShadow()
            // view.configureTheme(., iconStyle: <#T##IconStyle#>)
            
            //let iconText = "❌"
            (view.backgroundView as? CornerRoundingView)?.layer.cornerRadius = 10
            
            view.configureContent(title: "Message", body: "Please enter your full name to proceed.", iconText: "")
            SwiftMessages.show(view: view)
            view.button?.removeFromSuperview()
        }
    }
    
    func setSelectedIntrestsView(subVc:SelectedIntrestsCollectionViewController,inView:UIView, selectedItemsKey:String) {
        subVc.view.backgroundColor = .clear
        subVc.collectionView.backgroundColor = .clear
        subVc.selectedItemsKey = selectedItemsKey
//        if let arr = (UserDefaults.standard.object(forKey: selectedItemsKey) as? [String]) {
//            subVc.itemsArr = arr
//        }
        self.addChild(subVc)
        inView.addSubview(subVc.view)
        inView.addVisualConstraints(["H:|-8-[subVc]-50-|", "V:[subVc]|",], subviews: ["subVc":subVc.view])
        _ = subVc.view.addConstraintForHeight(51)
        subVc.didMove(toParent: self)
        subVc.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        self.view.endEditing(true)
        if(fullNameTxtField.text?.count ?? 0 > 0 && userNameTxtField.text?.count ?? 0 > 0) {
            saveUser()
            AppSettings.displayName = fullNameTxtField.text ?? ""
        }
        else {
            showMessageToEnterFullName()
        }
    }
    
    @IBAction func dismissBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bioBtnPressed(_ sender: Any) {
        if(fullNameTxtField.text?.count ?? 0 > 0) {
            bioScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 2860 + 43)
            UIView.animate(withDuration: 0.3) {
                self.bioScrollView.contentOffset = CGPoint.init(x: self.bioScrollView.contentOffset.x, y: self.bioScrollView.contentOffset.y + 300)
            }
        }
        else {
            showMessageToEnterFullName()
        }
    }
    
    @IBAction func proffesionBtnPressed(_ sender: UIButton) {
        currentSelectedList = professionSelectedList
        let selectedArr1 = userDocument?.data()[kProfessionKey] as? [String] ?? [String]()
        showProfessionInterestsPopUp(sender: sender, values:selectedArr1 , arrKey: kProfessionKey)
    }
    
    @IBAction func raceBtnPressed(_ sender: UIButton) {
        currentSelectedList = ethnicitySelectedList
        showPopUpItems(sender: sender, arr1:bioEthnicitys, arrKey: kEthnicityKey)
    }
    
    @IBAction func religionBtnPressed(_ sender: UIButton) {
        currentSelectedList = religionSelectedList
        showPopUpItems(sender: sender, arr1:bioReligion, arrKey: kReligionKey)
    }
    
    @IBAction func bodyTypeBtnPressed(_ sender: UIButton) {
        currentSelectedList = bodyTypeSelectedList
        showPopUpItems(sender: sender, arr1:bioBodyFigure, arrKey: kBodyTypeKey)
    }
    
    @IBAction func hairColorBtnPressed(_ sender: UIButton) {
        currentSelectedList = hairColorSelectedList
        showPopUpItems(sender: sender, arr1:bioHairColors, arrKey: kHairColorsKey)
    }
//    @IBAction func genderBtnPressed(_ sender: UIButton) {
//        currentSelectedList = genderSelectedList
//        showPopUpItems(sender: sender, arr1:bioGender, arrKey: kGenderKey)
//    }
    
    @IBAction func eyeColorBtnPressed(_ sender: UIButton) {
       currentSelectedList = eyeColorSelectedList
       showPopUpItems(sender: sender, arr1:bioEyeColors, arrKey: kEyeColorsKey)
    }
    
    @IBAction func relationshipBtnPressed(_ sender: UIButton) {
        currentSelectedList = relationshipSelectedList
        showInterestsPopUp(sender: sender, values:bioRelationship,arrKey: kReleationshipKey)
    }
    
    @IBAction func zoadicBtnPressed(_ sender: UIButton) {
        currentSelectedList = starSignSelectedList
        showInterestsPopUp(sender: sender, values:bioStarSign,arrKey: kStarSignKey)
    }
    
    @IBAction func educationBtnPressed(_ sender: UIButton) {
        currentSelectedList = educationSelectedList
        showPopUpItems(sender: sender, arr1:bioEducationLevel, arrKey: kEducationLevelKey)
    }
    
    @IBAction func kidsBtnPressed(_ sender: UIButton) {
        currentSelectedList = kidsSelectedList
        showPopUpItems(sender: sender, arr1:bioKids, arrKey: kKids)
    }
    
    @IBAction func dietBtnPressed(_ sender: UIButton) {
        currentSelectedList = dietrySelectedList
        showPopUpItems(sender: sender, arr1:bioDietryPreferences, arrKey: kDietryPreferences)
    }
    
    @IBAction func alchohalBtnPressed(_ sender: UIButton) {
        currentSelectedList = alchohalSelectedList
        showPopUpItems(sender: sender, arr1:bioAlchohal, arrKey: kAlchohal)
    }
    
    @IBAction func smokingBtnPressed(_ sender: UIButton) {
        currentSelectedList = smokingSelectedList
        showPopUpItems(sender: sender, arr1:bioSmoking, arrKey: kSmoking)
    }
    
    @IBAction func workoutBtnPressed(_ sender: UIButton) {
        currentSelectedList = workoutSelectedList
        showPopUpItems(sender: sender, arr1: bioWorkout, arrKey: kWorkout)
    }
    
    func showPopUpItems(sender: UIButton,arr1: Array<String>, arrKey:String) {
        showInterestsPopUp(sender: sender, values:arr1,arrKey: arrKey)
    }
    
    @IBAction func ownGenderBtnPressed(_ sender: UIButton) {
        currentSelectedList = genderSelectedList
        showPopUpItems(sender: sender, arr1:bioGender, arrKey: kGenderKey)
    }
    
    @IBAction func intrestedInBtnPressed(_ sender: UIButton) {
        currentSelectedList = intrestedSelectedList
        showPopUpItems(sender: sender, arr1:bioGender, arrKey: kIntrestedInKey)
    }
    
    
    @IBAction func currentRelationshipBtnPressed(_ sender: UIButton) {
        currentSelectedList = currentRelationshipStatusList
        showInterestsPopUp(sender: sender, values:bioCurrentRelationship,arrKey: kCurrentReleationshipKey)
    }
    
    
    @IBAction func getzipCodeBtnPressed(_ sender: Any) {
       
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    let ac = UIAlertController(title: nil, message: "Please provide us permission to accesss your location from settings.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    ac.addAction(UIAlertAction(title: "Settings", style: .destructive, handler: { _ in
                        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    }))
                    present(ac, animated: true, completion: nil)

                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.startUpdatingLocation()
                    SVProgressHUD.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let aGMSGeocoder: GMSGeocoder = GMSGeocoder()
                    aGMSGeocoder.reverseGeocodeCoordinate(self.locationManager.location!.coordinate) { (response, error) in
                        SVProgressHUD.dismiss()
                        if (error != nil) {
                            print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                            UIApplication.showMessageWith(error?.localizedDescription ?? "")
                            return
                        }
                        let gmsAddress: GMSAddress = response!.firstResult()!
                        self.gmsAddress1 = gmsAddress
                        if(self.gmsAddress1 == nil) {
                            UIApplication.showMessageWith("Please try again.")
                            return
                        }
                        self.locationManager.stopUpdatingLocation()
                        //stop updating location to save battery life
                        
                        self.postalCode = (gmsAddress.postalCode != nil) ? gmsAddress.postalCode : ""
                        self.zipCodeTxtField.text = self.postalCode
                     }
                    }
                }
            } else {
                let ac = UIAlertController(title: nil, message: "Please enable location from phone settings (Settings-> Privacy-> Location Services)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            
                present(ac, animated: true, completion: nil)
            }
        }
    
}

extension BioViewController {
    
    func datePickerRange() {
        let calendar = Calendar(identifier: .gregorian)
        
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = -18
        components.month = 0
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -100
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
    }
    
    @IBAction func dobBtnPressed(_ sender: Any) {

        UIView.animate(withDuration: 0.1) {
            self.datePickerContainer.isHidden = false
        }
    }
    
    @IBAction func datePickerDoneBtnPressed(_ sender: Any) {
        let dateStr = datePicker.date.string("dd-MMM-YYYY")
        dobTxtField.text = dateStr//("\(day)/\(month)/\(year)")
        UIView.animate(withDuration: 0.1) {
            self.datePickerContainer.isHidden = true
        }
        
    }
    
    @IBAction func datePickerCancelBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1) {
            self.datePickerContainer.isHidden = true
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        
    }
}

extension BioViewController: RangeSeekSliderDelegate {//income Selector
    
    func generateIncomeValues() {
        income.append("$0k")
        for i in 1...1000 {
            if(i == 1000) {
                income.append("$1M+")
            }
            else {
                income.append("$\(i)K")
            }
        }
        incomeSelector.minValue = 0.0
        incomeSelector.maxValue = CGFloat(income.count - 1)
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        let index: Int = Int(roundf(Float(minValue)))
        return income[index]
    }
    
    func  rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        let index: Int = Int(roundf(Float(maxValue)))
        return income[index]
    }
}

extension BioViewController {
    @IBAction func bioMedia1BtnPressed(_ sender: UIButton) {
        saveMedia(index: 0, sender: sender)
        
    }
    
    @IBAction func bioMedia2BtnPressed(_ sender: UIButton) {
        saveMedia(index: 1, sender: sender)
    }
    
    @IBAction func bioMedia3BtnPressed(_ sender: UIButton) {
        saveMedia(index: 2, sender: sender)
    }
    
    @IBAction func bioMedia4BtnPressed(_ sender: UIButton) {
        saveMedia(index: 3, sender: sender)
    }
    
    @IBAction func bioMedia5BtnPressed(_ sender: UIButton) {
        saveMedia(index: 4, sender: sender)
    }
    
    func saveMedia(index:Int, sender:UIButton) {
        self.shouldUpdateTxtFieldsAndRangeFromServer = false
        let picker = YPImagePicker()
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.bioPicsArr[index] = ""
                SVProgressHUD.show()
                self.uploadImage(photo.image, "bioPics", completion: { (url) in
                    //SDImageCache.shared.cl
                    self.bioPicsArr[index] = url?.absoluteString ?? ""
                    
                    SVProgressHUD.dismiss()
                })
                sender.setImage(photo.image, for: .normal)
                picker.dismiss(animated: true, completion: nil)
            }
            else {
                picker.dismiss(animated: true, completion: nil)
            }
            
            
        }
        present(picker, animated: true, completion: nil)
    }
    
    private func uploadImage(_ image: UIImage,_ folderName:String, completion: @escaping (URL?) -> Void) {

        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(user.uid).child(folderName).child(imageName).putData(data, metadata: metadata) { meta, error in
            if let error1 = error {
                UIApplication.showMessageWith(error1.localizedDescription)
                print(error1.localizedDescription)
                return
            }
            self.getDownloadURL(from: metadata.path!, completion: { (url, error) in
                if let error1 = error {
                    UIApplication.showMessageWith(error1.localizedDescription)
                    print(error1.localizedDescription)
                    return
                }
                completion(url)
            })
        }
    }
    // MARK: - GET DOWNLOAD URL
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
        storage.child(path).downloadURL(completion: completion)
    }
    
    
}


