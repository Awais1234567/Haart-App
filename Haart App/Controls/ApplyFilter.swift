//
//  ApplyFilter.swift
//  Haart App
//
//  Created by Stone on 17/04/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
class ApplyFilter {
    
    static func isQualified(currentUserSnapshot:QueryDocumentSnapshot, othrerUserSnapshot:QueryDocumentSnapshot) -> Bool {
        
        //current location distance
        let otherUserLocation = CLLocation.init(latitude: othrerUserSnapshot.data()["lat"] as? CLLocationDegrees ?? 0, longitude: othrerUserSnapshot.data()["lng"] as? CLLocationDegrees ?? 0)
        let currentUserLocation = CLLocation.init(latitude: currentUserSnapshot.data()["lat"] as? CLLocationDegrees ?? 0, longitude: currentUserSnapshot.data()["lng"] as? CLLocationDegrees ?? 0)
        let distance = CGFloat((currentUserLocation.distance(from: otherUserLocation)) / 1600)
        

        if(otherUserLocation.coordinate.latitude == 0 && otherUserLocation.coordinate.longitude == 0) {//that user has not added location
            return false
        }
        if(currentUserLocation.coordinate.latitude == 0 && currentUserLocation.coordinate.longitude == 0) { // current user has not added location
            return false
        }
        
//        if(currentUserSnapshot["filterEnabled"] as? Bool ?? false == false) { //if filter disabled
//            if(distance > 100) { // only show in 100 miles
//                return false
//            }
//            return true
//        }
        
        //income
        let otherUserMinIncome = (othrerUserSnapshot.data()["incomeMin"] as? CGFloat ?? 0)
        let otherUserMaxIncome = (othrerUserSnapshot.data()["incomeMax"] as? CGFloat ?? 0)
        let currentUserFilterMinIncome = (currentUserSnapshot.data()["filterIncomeMin"] as? CGFloat ?? 0)
        let currentUserFilterMaxIncome = (currentUserSnapshot.data()["filterIncomeMax"] as? CGFloat ?? 0)
        
        
        if(otherUserMinIncome < currentUserFilterMinIncome || otherUserMaxIncome > currentUserFilterMaxIncome) {
            return false
        }
        
        //filter zip code distance
        let filterLocation = CLLocation.init(latitude: currentUserSnapshot.data()["filterLat"] as? CLLocationDegrees ?? 0, longitude: currentUserSnapshot.data()["filterLng"] as? CLLocationDegrees ?? 0)
        
        if(filterLocation.coordinate.latitude != 0 && filterLocation.coordinate.longitude != 0) {//if user has add zip code in filter and filter is enabled
            let filterDistance = CGFloat((filterLocation.distance(from: otherUserLocation)) / 1600)
            if((filterDistance < (currentUserSnapshot.data()["filterDistanceMin"] as? CGFloat ?? 0) || filterDistance > (currentUserSnapshot.data()["filterDistanceMax"] as? CGFloat ?? 0))) {
                return false
            }
        }
        
        else if(distance < (currentUserSnapshot.data()["filterDistanceMin"] as? CGFloat ?? 0) || distance > (currentUserSnapshot.data()["filterDistanceMax"] as? CGFloat ?? 0)) {
            return false
        }
        
        //calculate age
        var outherUserAge:CGFloat = 0.0
        if let dob = othrerUserSnapshot.data()["dob"] as? String {
            if(dob.count > 0) {
                outherUserAge = CGFloat(dob.getAgeFromDOB().0)
            }
        }
        
        if(outherUserAge < (currentUserSnapshot.data()["filterAgeMin"] as? CGFloat ?? 0) || outherUserAge > (currentUserSnapshot.data()["filterAgeMax"] as? CGFloat ?? 0)) {
            return false
        }
        let filterMinHeight = currentUserSnapshot.data()["filterMinHeight"] as? CGFloat ?? 0
        let filterMaxHeight = currentUserSnapshot.data()["filterMaxHeight"] as? CGFloat ?? 0
        let otherUserHeight = othrerUserSnapshot.data()["height"] as? CGFloat ?? 0
        if(otherUserHeight <  filterMinHeight || otherUserHeight > filterMaxHeight) {
            return false
        }
        if(!((currentUserSnapshot.data()["fcurrentRelationship"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fcurrentRelationship"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fcurrentRelationship"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["currentRelationship"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["frelationships"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["frelationships"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["frelationships"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["relationships"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fworkout"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fworkout"] as? [String] ?? Array()).count > 0){
           
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fworkout"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["workout"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fsmoking"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fsmoking"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fsmoking"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["smoking"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["falchohal"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["falchohal"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["falchohal"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["alchohal"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fdietryPreferences"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fdietryPreferences"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fdietryPreferences"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["dietryPreferences"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fkids"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fkids"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fkids"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["kids"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["feducationLevel"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["feducationLevel"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["feducationLevel"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["educationLevel"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fstarSign"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fstarSign"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fstarSign"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["starSign"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fgender"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fgender"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fgender"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["gender"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fhairColors"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fhairColors"] as? [String] ?? Array()).count > 0){
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fhairColors"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["hairColors"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fbodyFigure"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fbodyFigure"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fbodyFigure"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["bodyFigure"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["fethnicitys"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["fethnicitys"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["fethnicitys"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["ethnicitys"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["freligion"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["freligion"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["freligion"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["religion"] as? [String] ?? Array()))) {
                return false
            }
        }
        if(!((currentUserSnapshot.data()["feyeColors"] as? [String] ?? Array()).contains("All")) && (currentUserSnapshot.data()["feyeColors"] as? [String] ?? Array()).count > 0){
            
            if(!(arrayContainsSameElements(firstArr:currentUserSnapshot.data()["feyeColors"] as? [String] ?? Array(), secondArr: othrerUserSnapshot.data()["eyeColors"] as? [String] ?? Array()))) {
                return false
            }
        }
        return true
    }
    
    
    static func arrayContainsSameElements(firstArr:[String], secondArr: [String]) -> Bool {
        return firstArr.count == secondArr.count && firstArr.sorted() == secondArr.sorted()
    }
}
