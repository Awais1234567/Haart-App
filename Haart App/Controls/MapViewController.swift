//
//  MapViewController.swift
//  Haart App
//
//  Created by Stone on 06/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import SDWebImage
class MapViewController: AbstractControl, GMSMapViewDelegate {


    @IBOutlet weak var myMapView: GMSMapView!
    private var appUsersReference: CollectionReference {
        return db.collection("users")
    }
     var itemsArr = Array<QueryDocumentSnapshot>()
    var currentUserSnapshot:QueryDocumentSnapshot!
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.myMapView?.isMyLocationEnabled = true
        myMapView.delegate = self
        //Location Manager code to fetch current location
        if(locationManager.location == nil) {
        }
        else {
            let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 17.0)
            self.myMapView?.animate(to: camera)
        }
        self.setNavBarButtons(letfImages: [], rightImage: [UIImage.init(), UIImage.init(named: "Chat")!])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAndSetData()
    }
    func getAndSetData() {
        SVProgressHUD.show()
        self.myMapView.clear()
        appUsersReference.getDocuments { (snapshot, error) in
            
            if let documents = snapshot?.documents {
                let user:User = Auth.auth().currentUser!
                self.itemsArr = documents
                for i in 0..<(documents.count) {
                    if(documents[i].data()["userId"] as! String == user.uid) {
                        self.currentUserSnapshot = documents[i]
                         AppSettings.currentUserSnapshot = self.currentUserSnapshot
                        break
                    }
                }
               
                for i in 0..<(documents.count) {
                    if((documents[i].data()["blocked"] as? Array<String> ?? [String]()).contains(user.uid) || ((self.currentUserSnapshot.data()["blocked"] as? Array<String> ?? [String]()).contains(documents[i].data()["userId"] as! String))) {
                        //if blocked do nothing
                    }
                    else if(((self.currentUserSnapshot.data()["followed"] as? Array<String> ?? Array<String>()).contains(documents[i].data()["userId"] as! String)) || ((self.currentUserSnapshot.data()["followedBy"] as? Array<String> ?? Array<String>()).contains(documents[i].data()["userId"] as! String))){
                        var cord = CLLocationCoordinate2D(latitude: documents[i].data()["lat"] as? CLLocationDegrees ?? 0, longitude: documents[i].data()["lng"] as? CLLocationDegrees ?? 0)
                        if(documents[i].data()["userId"] as! String == user.uid) {
                            if let cord1 = self.locationManager.location?.coordinate {
                                cord = cord1
                            }
                        }
                        
                        if (cord.latitude == 0 && cord.longitude == 0) {
                        }
                        else {
                            var imgUrl = ""
                            if let imgsArr = (documents[i].data()["bioPics"] as? [String]) {
                                if(imgsArr.count > 0) {
                                    imgUrl = imgsArr[0]
                                }
                            }
                            let iconView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
                            iconView.backgroundColor = .darkGray
                            iconView.layer.cornerRadius = 20
                            iconView.clipsToBounds = true
                            iconView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                            iconView.sd_setImage(with: URL(string:imgUrl), placeholderImage: nil)
                            let marker = HaartAppMarker(position: cord)
                            marker.userSnapshot = documents[i]
                            marker.iconView = iconView
                            marker.map = self.myMapView
                        }
                    }
                }
            }
            else {
                UIApplication.showMessageWith(error?.localizedDescription ?? "")
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let marker = marker as! HaartAppMarker
        var ethnicity = "Ethnicity None"
        if let ethnicitys = marker.userSnapshot.data()["ethnicitys"] as? [String] {
            if(ethnicitys.count > 0) {
                ethnicity = ethnicitys[0]
            }
        }
        var imgUrl = ""
        if let imgsArr = (marker.userSnapshot.data()["bioPics"] as? [String]) {
            if(imgsArr.count > 0) {
                imgUrl = imgsArr[0]
            }
        }
        
        let view = Bundle.main.loadNibNamed("PersonCalloutView", owner: self, options: nil)![0] as! PersonCalloutView
        view.set(userName:marker.userSnapshot.data()["userName"] as? String ?? "",name:marker.userSnapshot.data()["fullName"] as? String ?? "",dob:marker.userSnapshot.data()["dob"] as? String,ethnicity:ethnicity, imgUrl:imgUrl)
        return view
    }


    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = manager.location
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.myMapView?.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        locationManager.stopUpdatingLocation()
        
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
}
