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

import UIKit
import FirebaseAuth
import FirebaseMessaging
import GoogleSignIn
import SVProgressHUD
import Quickblox
class LoginController: UIViewController, GIDSignInDelegate{
  
/*******************  Email Log In **********************/
    func configureEmailLogIn(with email:String)  {
        SVProgressHUD.show()
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://talhashah.page.link/H3Ed")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
       
        Auth.auth().sendSignInLink(toEmail:email,
                                   actionCodeSettings: actionCodeSettings) { error in
                                    // ...
                                    SVProgressHUD.dismiss()
                                    if let error = error {
                                        UIApplication.showMessageWith(error.localizedDescription)
                                        return
                                    }
                                    UserDefaults.standard.set(email, forKey: "Email")
                                    UIApplication.showMessageWith("Check your email for link")
                                    // ...
        }
        
    }
    
/*********************************************************/

    
    
 /*******************  Gmail Log In **********************/
    func configureGmailLogIn()  {
        GIDSignIn.sharedInstance().delegate = self

        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            UIApplication.showMessageWith(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
         Auth.auth().signIn(with: credential) { (result, error) in
            if let user = Auth.auth().currentUser {
                AppSettings.displayName = user.displayName ?? "nil"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "AddAccountsViewController")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

    }
/*********************************************************/
    
    
    
    /******************** Log in by phone ************************/
    func configureLoginWithPhoneNumber(phoneNumber:String) {
        SVProgressHUD.show()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
           SVProgressHUD.dismiss()
            if let error = error {
                UIApplication.showMessageWith(error.localizedDescription)
                return
            }
            if let verificationID = verificationID {
               let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
                vc.verificationID = verificationID
                UIApplication.visibleViewController.present(vc, animated: true, completion: nil)
            }

        }
    }
    
    /******************** Quickblox signup ************************/
    
 }




