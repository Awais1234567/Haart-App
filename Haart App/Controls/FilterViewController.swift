//
//  FilterViewController.swift
//  Haart App
//
//  Created by Stone on 05/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import RangeSeekSlider
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import CoreLocation
import GoogleMaps
import Alamofire

class FilterViewController: InterestPopUpValues {
    var filterCordinate: CLLocationCoordinate2D?
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var ageSelector: RangeSeekSlider!
    @IBOutlet weak var heightSelector: RangeSeekSlider!
    @IBOutlet weak var distanceSelector: RangeSeekSlider!
    
    @IBOutlet weak var zipCodeTxtField: HaartTextField!
    @IBOutlet weak var currentRelationshipView: UIView!
    @IBOutlet weak var alchohalView: UIView!
    @IBOutlet weak var smokingView: UIView!
    @IBOutlet weak var workoutView: UIView!
    @IBOutlet weak var dietView: UIView!
    @IBOutlet weak var kidsView: UIView!
    @IBOutlet weak var relationshipView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var eyeColorView: UIView!
    @IBOutlet weak var hairColorView: UIView!
    @IBOutlet weak var bodyTypeView: UIView!
    @IBOutlet weak var religionView: UIView!
    @IBOutlet weak var ethnicityView: UIView!
    @IBOutlet weak var educationLevelView: UIView!
    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var starSignView: UIView!
    @IBOutlet weak var incomeSelector: RangeSeekSlider!
   // @IBOutlet weak var filtersSwitch: UISwitch!
    @IBOutlet weak var newMatchesCountLbl: UILabel!
    
    var currentRelationshipList:SelectedIntrestsCollectionViewController!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        generateIncomeValues()
        newMatchesCountLbl.isHidden = true
        heightSelector.handleImage = UIImage.init(named: "heartLike")
        heightSelector.handleDiameter = 22
        heightSelector.numberFormatter.numberStyle = .decimal
        heightSelector.numberFormatter.maximumSignificantDigits = 2
        heightSelector.numberFormatter.decimalSeparator = "'"
        heightSelector.numberFormatter.minimumFractionDigits = 1
        heightSelector.numberFormatter.minimumSignificantDigits = 1
        heightSelector.minValue = 3.0
        heightSelector.maxValue = 8.0
        heightSelector.delegate = self
        heightSelector.disableRange = false
        
        ageSelector.disableRange = false
        ageSelector.handleImage = UIImage.init(named: "heartLike")
        ageSelector.handleDiameter = 22
        ageSelector.delegate = self
        
        
        distanceSelector.numberFormatter.positiveSuffix = " mi"
        distanceSelector.handleImage = UIImage.init(named: "heartLike")
        distanceSelector.handleDiameter = 22
        distanceSelector.delegate = self
        
        incomeSelector.numberFormatter.numberStyle = .decimal
        incomeSelector.delegate = self
        incomeSelector.numberFormatter.maximumSignificantDigits = 2
        incomeSelector.numberFormatter.decimalSeparator = "'"
        incomeSelector.numberFormatter.minimumFractionDigits = 1
        incomeSelector.numberFormatter.minimumSignificantDigits = 1
        incomeSelector.disableRange = false
        incomeSelector.handleImage = UIImage.init(named: "heartLike")
        incomeSelector.handleDiameter = 22
        
        if #available(iOS 11.0, *){
            filterScrollView.contentInsetAdjustmentBehavior = .never
        }
        else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setSelectedIntrestsViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .clear
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .red
    }

    
    
    func layout() -> UICollectionViewFlowLayout {
        let  layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width:100, height:51)
        return layout
    }
    
    func getData() {
        if(self.userDocument == nil) {
            SVProgressHUD.show()
        }
        let ref = db.collection("users").whereField("userId", isEqualTo: self.user.uid)
        ref.getDocuments { (snapshot, error) in
            SVProgressHUD.dismiss()
            
            if(snapshot?.documents.count == 0) {
                
            }
            else {
                self.userDocument = snapshot?.documents[0]
                
               
                self.zipCodeTxtField.text = self.userDocument?["filterZipCode"] as? String ??  ""
                
                self.currentRelationshipList.userDocument = self.userDocument //calling didset
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
               // self.professionSelectedList.userDocument = self.userDocument
                self.eyeColorSelectedList.userDocument = self.userDocument
                self.relationshipSelectedList.userDocument = self.userDocument
                
                if(self.shouldUpdateTxtFieldsAndRangeFromServer == true) {
                    self.setNewMatchesCount()
                    self.heightSelector.selectedMaxValue = self.userDocument?.data()["filterMaxHeight"] as? CGFloat ?? CGFloat.init(8.0)
                    self.heightSelector.selectedMinValue = self.userDocument?.data()["filterMinHeight"] as? CGFloat ?? CGFloat.init(3.0)
                    self.heightSelector.layoutSubviews()
                    self.incomeSelector.selectedMinValue = self.userDocument?.data()["filterIncomeMin"] as? CGFloat ?? CGFloat.init(0)
                    self.incomeSelector.selectedMaxValue = self.userDocument?.data()["filterIncomeMax"] as? CGFloat ?? CGFloat.init(self.income.count - 1)
                    self.incomeSelector.layoutSubviews()
                    self.distanceSelector.selectedMinValue = self.userDocument?.data()["filterDistanceMin"] as? CGFloat ?? CGFloat.init(0.0)
                    self.distanceSelector.selectedMaxValue = self.userDocument?.data()["filterDistanceMax"] as? CGFloat ?? CGFloat.init(100.0)
                    self.distanceSelector.layoutSubviews()
                    self.ageSelector.selectedMinValue = self.userDocument?.data()["filterAgeMin"] as? CGFloat ?? CGFloat.init(18)
                    self.ageSelector.selectedMaxValue = self.userDocument?.data()["filterAgeMax"] as? CGFloat ?? CGFloat.init(100)
                    self.ageSelector.layoutSubviews()
                }
                self.shouldUpdateTxtFieldsAndRangeFromServer = true
            }
        }
    }
    
    override func didChangeValueForIntrests() {
       // filtersSwitch.isOn = true
    }
    func setNewMatchesCount() {
        let newMatchesCount = self.userDocument?["unreadMatchesCount"] as? Int ?? 0
//        if(self.filtersSwitch.isOn || newMatchesCount == 0) {
//            self.newMatchesCountLbl.isHidden = true
//        }
//        else {
//            self.newMatchesCountLbl.isHidden = false
            if(newMatchesCount == 1) {
                self.newMatchesCountLbl.text = "Turn Off Filter To See 1 New Match"
            }
            else {
                self.newMatchesCountLbl.text = "Turn Off Filter To See \(newMatchesCount) New Match"
            }
      //  }
    }
    @IBAction func filterToggle(_ sender: UISwitch) {
      //  SVProgressHUD.show()
        setNewMatchesCount()
       // self.userDocument!.reference.updateData(["filterEnabled":sender.isOn], completion: { (error) in
      //      SVProgressHUD.dismiss()
//            if let e = error {
//                UIApplication.showMessageWith(e.localizedDescription)
//            }
//            else {
//                if(sender.isOn){
//                    UIApplication.showMessageWith("Filters Enabled")
//                }
//                else {
//                    UIApplication.showMessageWith("Filters disabled")
//                }
         //   }
    //    })
    }
    
    func saveData() {
        var userData:[String:Any] = ["filterMinHeight":heightSelector.selectedMinValue, "filterMaxHeight":heightSelector.selectedMaxValue, "filterIncomeMin":incomeSelector.selectedMinValue, "filterIncomeMax":incomeSelector.selectedMaxValue, "filterDistanceMin":distanceSelector.selectedMinValue, "filterDistanceMax":distanceSelector.selectedMaxValue, "filterAgeMin":ageSelector.selectedMinValue, "filterAgeMax":ageSelector.selectedMaxValue, "fcmToken":AppSettings.deviceToken]
        if(self.filterCordinate != nil) {
            userData["filterLat"] = self.filterCordinate?.latitude ?? 0
            userData["filterLng"] = self.filterCordinate?.longitude ?? 0
            userData["filterZipCode"] = zipCodeTxtField.text ?? ""
        }
        print(userData)
        let document = self.userDocument!
        SVProgressHUD.show()
        document.reference.updateData(userData, completion: { (error) in
            SVProgressHUD.dismiss()
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func setSelectedIntrestsViews() {
        
        currentRelationshipList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: currentRelationshipList, inView: currentRelationshipView, selectedItemsKey: "fcurrentRelationship")
        
        relationshipSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: relationshipSelectedList, inView: relationshipView, selectedItemsKey: "frelationships")
        
        workoutSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: workoutSelectedList, inView: workoutView, selectedItemsKey: "fworkout")
        
        smokingSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: smokingSelectedList, inView: smokingView, selectedItemsKey: "fsmoking")
        
        alchohalSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: alchohalSelectedList, inView: alchohalView, selectedItemsKey: "falchohal")
        
        dietrySelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: dietrySelectedList, inView: dietView, selectedItemsKey: "fdietryPreferences")
        
        kidsSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: kidsSelectedList, inView: kidsView, selectedItemsKey: "fkids")
        
      
        
        educationSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: educationSelectedList, inView: educationLevelView, selectedItemsKey: "feducationLevel")
        
        starSignSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: starSignSelectedList, inView: starSignView, selectedItemsKey: "fstarSign")
        
        genderSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: genderSelectedList, inView: genderView, selectedItemsKey: "fgender")
        
        hairColorSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: hairColorSelectedList, inView: hairColorView, selectedItemsKey: "fhairColors")
        //
        bodyTypeSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: bodyTypeSelectedList, inView: bodyTypeView, selectedItemsKey: "fbodyFigure")
        
        ethnicitySelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: ethnicitySelectedList, inView: ethnicityView, selectedItemsKey: "fethnicitys")
        
        religionSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: religionSelectedList, inView: religionView, selectedItemsKey: "freligion")

        eyeColorSelectedList = SelectedIntrestsCollectionViewController.init(collectionViewLayout: layout())
        self.setSelectedIntrestsView(subVc: eyeColorSelectedList, inView: eyeColorView, selectedItemsKey: "feyeColors")
        setCollectionViewGestures()
    }
    
    func setCollectionViewGestures() {
        
        currentRelationshipList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(currentRelationshipBtnPressed(_:))))
        workoutSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(workoutBtnPressed(_:))))
        smokingSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(smokingBtnPressed(_:))))
        alchohalSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(alchoalBtnPressed(_:))))
        dietrySelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(dietBtnPressed(_:))))
        kidsSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(kidsBtnPressed(_:)) ))
      
        educationSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(educationBtnPressed(_:))))
        starSignSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(zoadicBtnPressed(_:))))
        genderSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(genderBtnPressed(_:))))
        hairColorSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hairColorBtnPressed(_:)) ))
        bodyTypeSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTypeBtnPressed(_:)) ))
        ethnicitySelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(raceBtnPressed(_:))))
        religionSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(religionBtnPressed(_:))))
        eyeColorSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(eyeColorBtnPressed(_:))))
        
        relationshipSelectedList.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(relationshipBtnPressed(_:))))
    }
    
    
    func setSelectedIntrestsView(subVc:SelectedIntrestsCollectionViewController,inView:UIView, selectedItemsKey:String) {
        subVc.view.backgroundColor = .clear
        subVc.collectionView.backgroundColor = .clear
        subVc.selectedItemsKey = selectedItemsKey
//        if let arr = (UserDefaults.standard.object(forKey: String("f\(selectedItemsKey)")) as? [String]) {
//            subVc.itemsArr = arr
//        }
        self.addChild(subVc)
        inView.addSubview(subVc.view)
        inView.addVisualConstraints(["H:|-8-[subVc]-50-|", "V:[subVc]|",], subviews: ["subVc":subVc.view])
        _ = subVc.view.addConstraintForHeight(51)
        subVc.didMove(toParent: self)
        subVc.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func doneBtnPressed(_ sender: Any) {
        saveData()
        
    }
    @IBAction func zipCodeBtnPressed(_ sender: Any) {  if CLLocationManager.locationServicesEnabled() {
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
                    self.filterCordinate = gmsAddress.coordinate
                    if(self.filterCordinate == nil) {
                        UIApplication.showMessageWith("Please try again.")
                        return
                    }
                    self.locationManager.stopUpdatingLocation()
                    //stop updating location to save battery life
                    self.zipCodeTxtField.text = gmsAddress.postalCode ?? ""
                }
            }
        }
    } else {
        let ac = UIAlertController(title: nil, message: "Please enable location from phone settings (Settings-> Privacy-> Location Services)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        
        present(ac, animated: true, completion: nil)
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == zipCodeTxtField) {
            geoCodeApiAddress()
        }
        
    }
    
    func geoCodeApiAddress() {
        SVProgressHUD.show()
       // let api = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)&key=AIzaSyD1kOEBHNFsq5D7Zwu_XSM6YWj0-Jw2j0c"
        let api = "https://maps.googleapis.com/maps/api/geocode/json?address=\(zipCodeTxtField.text ?? "")&key=AIzaSyD1kOEBHNFsq5D7Zwu_XSM6YWj0-Jw2j0c"

        AF.request(api, method: .get, parameters: [:], encoding: URLEncoding.default, headers: nil).responseJSON {(response: AFDataResponse<Any>) in
            SVProgressHUD.dismiss()
            switch(response.result) {
            case .success(_):
                if let data = response.data as? [String:Any]{
                   // print(data["results"] as! [String:Any])
                    if let results = data["results"] as? [[String:Any]] {
                        for obj in results {
                            if let geometry = obj["geometry"] as? [String:Any] {
                                if let location = geometry["location"] as? [String:Any] {
                                    
                                    if(location["lat"] as? CGFloat != nil) {
                                        let lat:CGFloat = location["lat"] as? CGFloat ?? 0
                                        let lng:CGFloat = location["lng"] as? CGFloat ?? 0
                                        
                                        self.filterCordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
                                    }
                                    else {
                                        UIApplication.showMessageWith("Please try again.")
                                    }

                                }
                            }
                        }
                    }
                    
                }
                break
            case .failure(_):
                UIApplication.showMessageWith(response.error?.localizedDescription ?? "Please try again later.")
                break
                
            }
        }
    }
    /////fgender means filter gender
    @IBAction func genderBtnPressed(_ sender: UIButton) {
        currentSelectedList = genderSelectedList
        self.showInterestsPopUp(sender: sender, values: filterGender, arrKey: "fgender")
    }
    @IBAction func eyeColorBtnPressed(_ sender: UIButton) {
        currentSelectedList = eyeColorSelectedList
        showInterestsPopUp(sender: sender, values:filterEyeColors, arrKey: "feyeColors")
    }
    @IBAction func bodyTypeBtnPressed(_ sender: UIButton) {
        currentSelectedList = bodyTypeSelectedList
        showInterestsPopUp(sender: sender, values:filterBodyFigure, arrKey: "fbodyFigure")
    }
    
    @IBAction func hairColorBtnPressed(_ sender: UIButton) {
        currentSelectedList = hairColorSelectedList
        showInterestsPopUp(sender: sender, values:filterHairColors, arrKey: "fhairColors")
    }
    
    @IBAction func smokingBtnPressed(_ sender: UIButton) {
        currentSelectedList = smokingSelectedList
        showInterestsPopUp(sender: sender, values:filterSmoking, arrKey: "fsmoking")
    }
   
    @IBAction func religionBtnPressed(_ sender: UIButton) {
        currentSelectedList = religionSelectedList
        showInterestsPopUp(sender: sender, values:filterReligion, arrKey: "freligion")
    }
    @IBAction func zoadicBtnPressed(_ sender: UIButton) {
        currentSelectedList = starSignSelectedList
        showInterestsPopUp(sender: sender, values:filterStarSign, arrKey: "fstarSign")
    }
    @IBAction func relationshipBtnPressed(_ sender: UIButton) {
        currentSelectedList = relationshipSelectedList
        showInterestsPopUp(sender: sender, values:filterAlchohal, arrKey: String("frelationships"))
    }
    @IBAction func alchoalBtnPressed(_ sender: UIButton) {
        currentSelectedList = alchohalSelectedList
        showInterestsPopUp(sender: sender, values:filterAlchohal, arrKey: "falchohal")
    }
    @IBAction func dietBtnPressed(_ sender: UIButton) {
        currentSelectedList = dietrySelectedList
        showInterestsPopUp(sender: sender, values:filterDietryPreferences, arrKey: "fdietryPreferences")
    }
    
    @IBAction func workoutBtnPressed(_ sender: UIButton) {
        currentSelectedList = workoutSelectedList
        showInterestsPopUp(sender: sender, values:filterWorkout, arrKey: "fworkout")
    }
    @IBAction func kidsBtnPressed(_ sender: UIButton) {
        currentSelectedList = kidsSelectedList
        showInterestsPopUp(sender: sender, values:filterKids, arrKey: "fkids")
    }
    @IBAction func educationBtnPressed(_ sender: UIButton) {
        currentSelectedList = educationSelectedList
        showInterestsPopUp(sender: sender, values: filterEducationLevel, arrKey: "feducationLevel")
    }
   
    @IBAction func raceBtnPressed(_ sender: UIButton) {
        currentSelectedList = ethnicitySelectedList
        showInterestsPopUp(sender: sender, values:filterEthnicitys, arrKey: "fethnicitys")
    }
    @IBAction func currentRelationshipBtnPressed(_ sender: UIButton) {
        currentSelectedList = currentRelationshipList
        showInterestsPopUp(sender: sender, values:filterCurrentRelationship, arrKey: "fcurrentRelationship")
    }
    @IBAction func resetBtnPressed(_ sender: Any) {
        SVProgressHUD.show()
        var userData = [String:Any]()
        
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
        
        if(((userData["zipCode"] as? String) ?? "").count != 0) {
            userData["filterLat"] = userDocument?.data()["lat"] as? CLLocationDegrees ?? 0
            userData["filterLng"] = userDocument?.data()["lng"] as? CLLocationDegrees ?? 0
            userData["filterZipCode"] = userDocument?.data()["zipCode"] as? String ?? ""
            zipCodeTxtField.text = userDocument?.data()["zipCode"] as? String ?? ""
        }
        
        
        let document = self.userDocument!
        document.reference.updateData(userData, completion: { (error) in
            SVProgressHUD.dismiss()
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                self.shouldUpdateTxtFieldsAndRangeFromServer = true
                SVProgressHUD.show()
                self.getData()
            }
        })
    }
}

extension FilterViewController: RangeSeekSliderDelegate {//income Selector
    
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
        if (slider == incomeSelector) {
            let index: Int = Int(roundf(Float(minValue)))
            return income[index]
        }
        return nil
    }
    
    func  rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        if (slider == incomeSelector) {
            let index: Int = Int(roundf(Float(maxValue)))
            return income[index]
        }
        return nil
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        //filtersSwitch.isOn = true
    }
    
}
