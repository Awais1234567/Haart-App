//
//  LoginViewController.swift
//  Haart App
//
//  Created by Stone on 10/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import CountryPickerView

class LoginViewController: AbstractControl {
@IBOutlet weak var placeHolder: UILabel!
    var placeholderText = ""
    var cp:CountryPickerView!
    weak var cpvTextField: CountryPickerView!

    @IBOutlet weak var txtField: HaartTextField!
    @IBOutlet weak var proceedBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        placeHolder.text = placeholderText
        proceedBtn.layer.borderColor = UIColor.red.cgColor
        if(placeholderText == "Email") {
            txtField.textContentType = .emailAddress
            txtField.keyboardType = .emailAddress
        }
        else {
            txtField.textContentType = .telephoneNumber
            txtField.keyboardType = .phonePad
            setCountryView()
        }
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        proceedBtn.layer.cornerRadius = proceedBtn.frame.size.height / 2.0

    }
    
    func setCountryView() {
        cp = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        cp.font = txtField.font!
        txtField.leftView = cp
        txtField.leftViewMode = .always
        self.cpvTextField = cp
        cpvTextField.dataSource = self
        cpvTextField.tag = 2
    }
    
    @IBAction func proceedBtnPressed(_ sender: Any) {
        let controller = LoginController()
      //  controller.configureGmailLogIn()
        if(placeholderText == "Email") {
            controller.configureEmailLogIn(with: txtField.text ?? "")
        }
        else {
            controller.configureLoginWithPhoneNumber(phoneNumber: "\(cp.selectedCountry.phoneCode)\(txtField.text ?? "")")
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}


extension LoginViewController: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        // Only countryPickerInternal has it's delegate set
       // let title = "Selected Country"
      //  let message = "Name: \(country.name) \nCode: \(country.code) \nPhone: \(country.phoneCode)"
        
      //  showAlert(title: title, message: message)
    }
}

extension LoginViewController: CountryPickerViewDataSource {
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {

        return []
    }
    
    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {

        return nil
    }
    
    func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
        return false//countryPickerView.tag == cpvMain.tag && showOnlyPreferredCountries.isOn
    }
    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country"
    }
    
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .navigationBar
    }
    
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return false
    }
    
    func showCountryCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return false
    }
}

