/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import FirebaseFirestore
final class AppSettings {
  
  private enum SettingKey: String {
    case displayName
  }
  
    static var currentUserSnapshot:QueryDocumentSnapshot?
        
    
    
   static var profilePicUrl:String! {
        get {
            return UserDefaults.standard.object(forKey: "profilePicUrl") as? String ?? ""
        }
        set {
            if let url = newValue {
                UserDefaults.standard.set(url, forKey: "profilePicUrl")
            }
            
        }
    }
    
    static var fullName:String! {
        get {
            return UserDefaults.standard.object(forKey: "fullName") as? String ?? ""
        }
        set {
            if let url = newValue {
                UserDefaults.standard.set(url, forKey: "fullName")
            }
            
        }
    }
    
    static var deviceToken:String! {
        get {
            return UserDefaults.standard.object(forKey: "deviceToken") as? String ?? ""
        }
        set {
            if let url = newValue {
                UserDefaults.standard.set(url, forKey: "deviceToken")
            }
            
        }
    }
    
    static var userName:String! {
        get {
            return UserDefaults.standard.object(forKey: "userName") as? String ?? ""
        }
        set {
            if let url = newValue {
                UserDefaults.standard.set(url, forKey: "userName")
            }
            
        }
    }
    
  static var displayName: String! {
    get {
      return UserDefaults.standard.string(forKey: SettingKey.displayName.rawValue)
    }
    set {
      let defaults = UserDefaults.standard
      let key = SettingKey.displayName.rawValue
      
      if let name = newValue {
        defaults.set(name, forKey: key)
      } else {
        defaults.removeObject(forKey: key)
      }
    }
  }
  
}
