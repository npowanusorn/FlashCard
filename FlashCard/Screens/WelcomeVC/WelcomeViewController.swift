//
//  WelcomeViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var googleButton: BounceButton!
    @IBOutlet weak var emailButton: BounceButton!
    @IBOutlet weak var createAccountButton: BounceButton!
    @IBOutlet weak var optionsView: UIView!
    
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
        Log.info("SIGN IN WITH GOOGLE TAPPED")
    }
    
    func goToNextVC() {
        let signUpSignInVC = SignUpSignInViewController()
        self.navigationController?.pushViewController(signUpSignInVC, animated: true)
    }
    
    private func animateElements() {
        Log.info("ANIMATE")

        let yTranslation = view.frame.height / 5
        optionsView.fadeIn()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.headerLabel.transform = CGAffineTransform(translationX: 0, y: -yTranslation).scaledBy(x: 0.9, y: 0.9)
            self.optionsView.transform = CGAffineTransform(translationX: 0, y: -20)
        }
//        UIView.animate(withDuration: 1) {
//            self.optionsView.transform = CGAffineTransform(translationX: 0, y: -20)
//        }
    }

}
