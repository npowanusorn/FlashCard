//
//  AppDelegate.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import SwiftyBeaver
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let log = SwiftyBeaver.self

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        _ = Firestore.firestore()
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                Log.info("unable to restore previous signin")
//                AppCache.shared.isAppSignedIn = false
            } else {
                Log.info("restored previous signin")
                AppCache.shared.hasRestoredPreviousGoogleSignIn = true
                AppCache.shared.user = user
            }
        }
        
        AppCache.shared.isSignInTapped = nil
        
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss$d $C$L$c $N.$F:$l - $M"
        log.addDestination(console)
        
        return true
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
        return GIDSignIn.sharedInstance.handle(url)
    }

}

