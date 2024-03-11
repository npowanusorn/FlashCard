//
//  SplashViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import UIKit
import KeychainSwift
import ProgressHUD

class SplashViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var spinIndicator: UIActivityIndicatorView!
    
    private var isAnimationDone = false
    private var isFirebaseDone = false
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
            if self.isFirebaseDone {
                self.navigateToNextScreen(isSignedIn: self.isSignedIn)
                return
            }
            self.spinIndicator.isHidden = false
            self.spinIndicator.startAnimating()
        }
        
        Task {
            await attemptToLogIn()
        }
    }
    
    private func attemptToLogIn() async {
        let rememberMe = defaults.bool(forKey: K.Defaults.rememberMe)
        Log.info("REMEMBER ME: \(rememberMe)")
        if rememberMe {
            guard let email = keychain.get(K.Keychain.email), let password = keychain.get(K.Keychain.password) else { return }
            let success = await AuthManager.signIn(email: email, password: password, viewController: self)
            if success {
                self.isSignedIn = true
                await attemptToGetData()
                isFirebaseDone = true
                if isAnimationDone { self.navigateToNextScreen(isSignedIn: self.isSignedIn)}
            }
        } else {
            self.isFirebaseDone = true
        }
    }
    
    private func attemptToGetData() async {
        await FirestoreManager.getData()
    }
    
    private func navigateToNextScreen(isSignedIn: Bool) {
        if isSignedIn {
            let homeVC = HomeViewController()
            self.navigationController?.pushViewController(homeVC, animated: true)
        } else {
            let welcomeVC = WelcomeViewController()
            self.navigationController?.viewControllers = [welcomeVC]
//            self.navigationController?.pushViewController(welcomeVC, animated: true, completion: {
//                self.navigationController?.viewControllers = [welcomeVC]
//            })
//            self.navigationController?.pushViewController(welcomeVC, animated: true)
        }
    }

}
