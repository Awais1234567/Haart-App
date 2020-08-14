//
//  AppDelegate.swift
//  Haart App
//
//  Created by Stone on 25/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//


extension UIApplication {
    var statusBarView: UIView? {
        
        if #available(iOS 13.0, *) {
            if responds(to: #selector(getter: UIWindowScene.statusBarManager)) {
                return value(forKey: "statusBarManager") as? UIView
            }
        } else {
            // Fallback on earlier versions
        }
        return nil
    }
}
let googleAPIKey = "AIzaSyAI1hrOvSRddk8p6tOkxHFZdahdLYeSJ68"
import UIKit
import GoogleMaps
import GooglePlaces
import DropDown
import IQKeyboardManagerSwift
import Firebase
import GoogleSignIn
import FirebaseAuth
import SVProgressHUD
import YPImagePicker
import FirebaseMessaging
import NotificationView
import Quickblox
import QuickbloxWebRTC
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?

    var isCalling = false {
        didSet {
            if UIApplication.shared.applicationState == .background,
                isCalling == false, CallKitManager.instance.isHasSession() {
                disconnect()
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotification(application: application)
            // for default navigation bar title color
        SVProgressHUD.setDefaultMaskType(.clear)
        YPImagePickerConfiguration.shared.showsPhotoFilters = true

        IQKeyboardManager.shared.enable = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        DropDown.startListeningToKeyboard()
        GMSServices.provideAPIKey(googleAPIKey)
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "com.talhashah.Haart-App"

        AppController.shared.show(in: self.window)
        Messaging.messaging().delegate = self
        configQuickBlox()
        
        return true
    }
    
    func registerForPushNotification(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        AppSettings.deviceToken = fcmToken
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("users").whereField("userId", isEqualTo: userId)
            ref.getDocuments { (snapshot, error) in
                if(snapshot?.documents.count ?? 0 > 0) {
                    snapshot?.documents[0].reference.updateData(["fcmToken":fcmToken])
                }
            }
        }
    }
   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handleNotification(senderId: userInfo["senderId"] as? String ?? "nil", notificationType: userInfo["type"] as? String ?? "nil")


        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handleNotification(senderId: userInfo["senderId"] as? String ?? "nil", notificationType: userInfo["type"] as? String ?? "nil")
        // Print full message.
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let _ = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            return true
        }
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
   
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            let link = dynamiclink?.url?.absoluteString ?? ""
            SVProgressHUD.show()
            if Auth.auth().isSignIn(withEmailLink: link) {
                SVProgressHUD.dismiss()
                SVProgressHUD.show()
                Auth.auth().signIn(withEmail: UserDefaults.standard.value(forKey: "Email") as? String ?? "" , link: link) { (user, error) in
                    SVProgressHUD.dismiss()
                    if (user?.user.isEmailVerified == true) {
                        if let user = Auth.auth().currentUser {
                            AppSettings.displayName = user.displayName ?? "nil"
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "AddAccountsViewController")
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                        } else {
                            
                        }
                      }
                    }
                }
            }
        
        return handled
    }
    func applicationWillTerminate(_ application: UIApplication) {
        disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        if QBChat.instance.isConnected == true {
            return
        }
        connect { (error) in
            if let error = error {
                debugPrint("Connect error: \(error.localizedDescription)")
                return
            }
            SVProgressHUD.showSuccess(withStatus: "Connected")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        connect()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        setUserState(isActive: "0")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        setUserState(isActive: "1")
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "")
    }
    
    /*
     User State can only be 1 or 0
     1 = Active
     0 = InActive
     */
    func setUserState(isActive: String){
        if let currentUser = Auth.auth().currentUser{
            let controller = AbstractControl()
            let ref = controller.db.collection("users").whereField("userId", isEqualTo: currentUser.uid)
            ref.getDocuments { (snapshot, error) in
                let userData = ["isActive":isActive] as [String : Any]
                snapshot?.documents[0].reference.updateData(userData, completion: {error in
                })
            }
        }
    }
    

}

@available(iOS 10, *)
extension AppDelegate: NotificationViewDelegate  {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let notificationView = NotificationView.default
        notificationView.title = notification.request.content.title
    //    notificationView.subtitle = "subtitle"
        notificationView.body = notification.request.content.body
       // notificationView.image = image
        notificationView.param = userInfo
        notificationView.show()
        notificationView.delegate = self
        print(userInfo)
    
        // Change this to your preferred presentation option
        completionHandler([])
    }
    func notificationViewDidTap(_ notificationView: NotificationView) {
        notificationView.hide()
        let userInfo = notificationView.param
        handleNotification(senderId: userInfo?["senderId"] as? String ?? "nil", notificationType: userInfo?["type"] as? String ?? "nil")

        print("delegate: notificationViewDidTap")
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        handleNotification(senderId: userInfo["senderId"] as? String ?? "nil", notificationType: userInfo["type"] as? String ?? "nil")
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
    }
    
    func handleNotification(senderId:String, notificationType:String) {
        if (!UserDefaults.standard.bool(forKey: "isLoggedIn")) {
            return
        }
        print(senderId, "  ",notificationType)
        if let user = Auth.auth().currentUser {
            if(notificationType == "Message") {
                let db = Firestore.firestore()
                let channelReference = db.collection("channels").whereField("userIds", arrayContains: user.uid)
                SVProgressHUD.show()
                channelReference.getDocuments(completion: { (snapshot, error) in
                    
                    var doc:QueryDocumentSnapshot?
                    for document in snapshot?.documents ?? [QueryDocumentSnapshot]() {
                        if((document.data()["userIds"] as! NSArray).contains(senderId)) {
                            doc = document
                            break
                        }
                    }
                    SVProgressHUD.dismiss()
                    if (doc != nil) {
                        let channel = Channel.init(document: doc!)
                        let vc = ChatViewController(user: user, channel: channel!)
                        UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
                    }
                })
            }
            else if(notificationType == "New Match") {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MatchesViewController")
                if let nv = UIApplication.visibleViewController.navigationController {
                    nv.pushViewController(vc, animated: true)
                }
                else {
                    UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
                }
            }
            else if(notificationType == "Like") {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LikedViewController") as! LikedViewController
                vc.listType = .liked
                if let nv = UIApplication.visibleViewController.navigationController {
                    nv.pushViewController(vc, animated: true)
                }
                else {
                    UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
                }
            }
            else if(notificationType == "Super Like") {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LikedViewController") as! LikedViewController
                vc.listType = .superLiked
                if let nv = UIApplication.visibleViewController.navigationController {
                    nv.pushViewController(vc, animated: true)
                }
                else {
                    UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
                }
            }
            else if(notificationType == "Recommendation") {
                openFriendsNotification(listType: .suggested)
            }
            else if(notificationType == "Follow Request") {
                openFriendsNotification(listType: .pending)
            }
            else if(notificationType == "Request Accepted") {
                openFriendsNotification(listType: .followed)
            }
        }
    }
    
    func openFriendsNotification(listType:ListType) {
        
        if let rootVC = UIApplication.rootViewController as? HaartTabViewCotroller {
            rootVC.selectedIndex = 1
            if(UIApplication.visibleViewController.navigationController == nil) {
                UIApplication.visibleViewController.dismiss(animated: false) {
                    if let nv = UIApplication.visibleViewController.navigationController {
                        for vc in nv.viewControllers {
                            if let selectedVc = vc as? FriendsViewController {
                                selectedVc.listType = listType
                                selectedVc.viewWillAppear(false)
                                if(listType == .pending) {
                                    selectedVc.segmentedControl.selectItemAt(index: 3)
                                }
                                else if(listType == .followed) {
                                    selectedVc.segmentedControl.selectItemAt(index: 1)
                                }
                                if(listType == .suggested) {
                                    selectedVc.segmentedControl.selectItemAt(index: 2)
                                }
                            }
                        }
                    }
                }
            }
            else {
                if let nv = UIApplication.visibleViewController.navigationController {
                    for vc in nv.viewControllers {
                        if let selectedVc = vc as? FriendsViewController {
                            selectedVc.listType = listType
                            selectedVc.viewWillAppear(false)
                            if(listType == .pending) {
                                selectedVc.segmentedControl.selectItemAt(index: 3)
                            }
                            else if(listType == .followed) {
                                selectedVc.segmentedControl.selectItemAt(index: 1)
                            }
                            if(listType == .suggested) {
                                selectedVc.segmentedControl.selectItemAt(index: 2)
                            }
                        }
                    }
                }
                
            }
          
        }
    }
}

//MARK: - QuickBlox Configuration
struct QuickBloxCredentialsConstant {
     static let applicationID:UInt = 84065
     static let authKey = "JXCVrXtYuAjMnyQ"
     static let authSecret = "4dS2fwK52FsmnKA"
     static let accountKey = "BnamoYdzTM-eN5qznUn-"
}
struct AppDelegateConstant {
    static let enableStatsReports: UInt = 1
}
struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 60.0
    static let dialingTimeInterval: TimeInterval = 5.0
}


extension AppDelegate{
    func configQuickBlox(){
        
        QBSettings.applicationID = QuickBloxCredentialsConstant.applicationID;
        QBSettings.authKey = QuickBloxCredentialsConstant.authKey
        QBSettings.authSecret = QuickBloxCredentialsConstant.authSecret
        QBSettings.accountKey = QuickBloxCredentialsConstant.accountKey
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.nothing
        QBSettings.disableXMPPLogging()
        QBSettings.disableFileLogging()
        QBRTCConfig.setLogLevel(QBRTCLogLevel.nothing)
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        QBRTCClient.initializeRTC()
    }
    //MARK: - Connect/Disconnect
    func connect(completion: QBChatCompletionBlock? = nil) {
        let currentUser = QuickBloxProfile()
        
        guard currentUser.isFull == true else {
            completion?(NSError(domain: "com.q-municate.chatservice",
                                code: -1000,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Please enter your login and username."
                ]))
            return
        }
        if QBChat.instance.isConnected == true {
            completion?(nil)
        } else {
            QBSettings.autoReconnectEnabled = true
            QBChat.instance.connect(withUserID: currentUser.ID, password: currentUser.password, completion: completion)
        }
    }
    
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        QBChat.instance.disconnect(completionBlock: completion)
    }
}
/* notification types
 Message
 New Match
 Like
 Super Like
 Recommendation
Follow Request
Request Accepted

 
 */
