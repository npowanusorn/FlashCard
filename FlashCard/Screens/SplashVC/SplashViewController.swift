//
//  SplashViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import UIKit
import KeychainSwift
import ProgressHUD
import FirebaseAuth

class SplashViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var spinIndicator: UIActivityIndicatorView!
    
    private var isAnimationDone = false
    private var isSignInAttemptCompleted = false
    private var isSignedIn = false
    
    private let defaults = UserDefaults.standard
    private let keychain = KeychainSwift()
    
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        spinIndicator.isHidden = true
        mainLabel.setTextWithTypingAnimation("FlashCard") {
            Log.info("DONE ANIMATION")
            self.isAnimationDone = true
            if self.isSignInAttemptCompleted {
                self.navigateToNextScreen(isSignedIn: self.isSignedIn)
                return
            }
            self.spinIndicator.isHidden = false
            self.spinIndicator.startAnimating()
        }
        
        if AppCache.shared.isAppGoogleSignedIn {
            Log.info("wait to restore previous session")
            DispatchQueue.global(qos: .userInitiated).async {
                while !AppCache.shared.hasRestoredPreviousGoogleSignIn {
                    usleep(50000)
                }
                main {
                    Task {
                        await self.attemptToLogIn()
                    }
                }
            }
        } else {
            Log.info("not google - no need to restore previous session")
            Task {
                await attemptToLogIn()
            }
        }
    }
    
    private func attemptToLogIn() async {
        let rememberMe = AppCache.shared.isAppSignedIn
        Log.info("REMEMBER ME: \(rememberMe)")
        Log.info("IS GOOGLE SIGN IN: \(AppCache.shared.isAppGoogleSignedIn)")
        if AppCache.shared.isAppGoogleSignedIn {
            guard let user = AppCache.shared.user, let idToken = user.idToken?.tokenString else {
                Log.error("unable to get AppCache.shared.user or user.idToken?.tokenString")
                self.isSignedIn = false
                self.isSignInAttemptCompleted = true
                return
            }
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            let success = await AuthManager.signIn(with: credentials)
            if success {
                self.isSignedIn = true
                await attemptToGetData()
                isSignInAttemptCompleted = true
                if isAnimationDone {
                    self.navigateToNextScreen(isSignedIn: self.isSignedIn)
                    return
                }
            }
        } else if rememberMe {
            guard let email = keychain.get(K.Keychain.email), let password = keychain.get(K.Keychain.password) else {
                Log.error("unable to get email/password from keychain")
                self.isSignedIn = false
                isSignInAttemptCompleted = true
                return
            }
            let success = await AuthManager.signIn(email: email, password: password, viewController: self)
            if success {
                self.isSignedIn = true
                await attemptToGetData()
                isSignInAttemptCompleted = true
                if isAnimationDone {
                    self.navigateToNextScreen(isSignedIn: self.isSignedIn)
                    return
                }
            }
        }
        
        self.isSignInAttemptCompleted = true
        if isAnimationDone {
            self.navigateToNextScreen(isSignedIn: self.isSignedIn)
            return
        }
    }
    
    private func attemptToGetData() async {
        await FirestoreManager.getData(isFromAppLaunch: true)
    }
    
    private func navigateToNextScreen(isSignedIn: Bool) {
        if isSignedIn {
            goToHome()
        } else {
            let welcomeVC = WelcomeViewController()
            self.navigationController?.viewControllers = [welcomeVC]
        }
    }

}
