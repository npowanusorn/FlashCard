//
//  WelcomeViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import ProgressHUD
import KeychainSwift

class WelcomeViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var googleButton: BounceButton!
    @IBOutlet weak var emailButton: BounceButton!
    @IBOutlet weak var createAccountButton: BounceButton!
    @IBOutlet weak var optionsView: UIView!
    
    private var shouldAnimate: Bool {
        AppCache.shared.shouldWelcomeVCAnimate
    }
    private let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: true)
        optionsView.alpha = 0
        animateElements()
    }

    @IBAction func signUpTapped(_ sender: Any) {
        AppCache.shared.isSignInTapped = false
        goToNextVC()
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        AppCache.shared.isSignInTapped = true
        goToNextVC()
    }
    
    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else { return }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            ProgressHUD.animationType = .horizontalDotScaling
            ProgressHUD.colorHUD = .systemGroupedBackground
            ProgressHUD.animate()
            
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credentials) { _, error in
                guard error == nil else { return }
                Task {
                    await FirestoreManager.getData()
                    self.goToHome(isFromSplash: false)
                    ProgressHUD.dismiss()
                    UserDefaults.standard.set(true, forKey: K.Defaults.isGoogleSignedIn)
                    self.keychain.set(idToken, forKey: K.Keychain.idToken)
                    self.keychain.set(user.accessToken.tokenString, forKey: K.Keychain.tokenString)
                }
            }
        }
    }
    
    func goToNextVC() {
        let signUpSignInVC = SignUpSignInViewController()
        self.navigationController?.pushViewController(signUpSignInVC, animated: true)
    }
    
    private func animateElements() {
        Log.info("ANIMATE")

        let yTranslation = view.frame.height / 5
        let duration: TimeInterval = shouldAnimate ? 1 : 0
        optionsView.fadeIn(duration: duration)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.headerLabel.transform = CGAffineTransform(translationX: 0, y: -yTranslation).scaledBy(x: 0.9, y: 0.9)
            self.optionsView.transform = CGAffineTransform(translationX: 0, y: -20)
        }
    }

}
