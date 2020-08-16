//
//  HaartSearchbar.swift
//  Haart App
//
//  Created by Stone on 12/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol HaartSearchBarDelegate: class {
    func filteredArr(_ arr: Array<String>)
}

class HaartSearchbar: UITextField, UITextFieldDelegate{
    
    var searchImageView:UIImageView!
    var tblView:UITableView!
    var items:Array<String>!
    let padding = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
    weak var searchDelegate: HaartSearchBarDelegate?
    let interestValue = InterestPopUpValues()
    let interestPopUp = InterestsPopUpViewController()
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
   override func draw(_ rect: CGRect) {
       super.drawText(in: rect)
        self.delegate = self
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchImageView.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchImageView.isHidden = self.text?.isEmpty != true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("-->\(interestPopUp.arrKey)")
        if(interestPopUp.arrKey == "movies" || interestPopUp.arrKey == "books" ){    interestValue.movies.append("hulk")
        print(interestValue.movies)
        print(interestValue.bioMovies)
        interestPopUp.itemsArr = interestValue.bioMovies
        DispatchQueue.main.async {
            self.interestPopUp.searchTblView.reloadData()
        }
 }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var searchString = String()
        if string.count == 0 {
            searchString = textField.text ?? ""
            searchString.removeLast()
        }
        else {
            searchString = "\(String(textField.text ?? ""))\(string)"
        }
        if(searchString.count == 0) {
            searchDelegate?.filteredArr(items)
            return true
        }
      //  searchString = searchString + "*"
        let predicate = NSPredicate(format: "SELF CONTAINS[cd] %@", searchString)
        let filteredArr:Array<String> = (items as NSArray).filtered(using: predicate) as! Array<String>
        searchDelegate?.filteredArr(filteredArr)
        return true
    }
}
