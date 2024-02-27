//
//  AppDelegate.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import UIKit
import iamport_ios
import Firebase
import FirebaseMessaging
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @DefaultsState(\.deviceToken) var deviceToken
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

//        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        // 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in})
//        application.registerForRemoteNotifications()
//        Messaging.messaging().delegate = self
        
        return true
    }
    // Firebase에서 APNS 토큰 연동이 끝났다.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error{
                print("Error fetching FCM Token : \(error)")
            }else if let token{
                print("successToken \(token)")
                Task{
                    do{
                        try await NM.shared.updateDeviceToken(deviceToken: token)
                        self.deviceToken = token
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Iamport.shared.receivedURL(url)
        return true
    }
}

extension AppDelegate:MessagingDelegate{
    // FCM 토큰을 등록한다.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let token = String(describing: fcmToken)
        print("Firebase registration token: \(token)")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post( name: Notification.Name("FCMToken"),object: nil,userInfo: dataDict)
    }
    // foreground에서 메시지 받기
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("message recive!!")
        completionHandler([.list, .banner,.badge])
    }
    // background에서 메시지 받기
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("message receive!!")
        print(response.notification.request.content.userInfo)
    }
}
