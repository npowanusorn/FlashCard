//
//  SignUpSignInViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class SignUpSignInViewController: UIViewController {

    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var confirmPasswordLbl: UILabel!
    @IBOutlet weak var emailTextField: BaseTextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var confirmPasswordTextField: PasswordTextField!
    @IBOutlet weak var passwordValidationLbl: UILabel!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var continueButton: BounceButton!
    @IBOutlet weak var resetPasswordButton: BounceButton!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var rememberMeViewToConfirmViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var validationLabelToTextFieldConstraint: NSLayoutConstraint!
    var validationText: String {
        get { passwordValidationLbl.text ?? "" }
        set { passwordValidationLbl.text = newValue }
    }
    
    let isSignIn = AppCache.shared.isSignInTapped!
    private var email: String { emailTextField.text ?? "" }
    private var password: String { passwordTextField.text ?? "" }
    private var confirmPassword: String { confirmPasswordTextField.text ?? "" }
    private var isPasswordMatch: Bool {
        if isSignIn {
            return !password.isEmpty
        } else {
            return password == confirmPassword && !password.isEmpty
        }
    }
    private var isEmailPasswordEmpty: Bool {
        email.isEmpty || password.isEmpty
    }
    private var isValidEmail: Bool { Validator.isValidEmail(email) }
    private var isValidPassword: Bool { password.count >= 6 }
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    @IBAction func textFieldDidBeginEdit(_ sender: Any) {
        Log.info("did begin edit")
        guard let textField = sender as? BaseTextField else { return }
        if textField == emailTextField {
            emailTextField.setWhiteBorder()
            passwordTextField.removeBorder()
            confirmPasswordTextField.removeBorder()
        } else if textField == passwordTextField {
            passwordTextField.setWhiteBorder()
            emailTextField.removeBorder()
            confirmPasswordTextField.removeBorder()
        } else {
            confirmPasswordTextField.setWhiteBorder()
            emailTextField.removeBorder()
            passwordTextField.removeBorder()
        }
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if !isValidEmail {
            continueButton.isEnabled = false
            if !email.isEmpty {
                passwordValidationLbl.isHidden = false
                validationText = "Invalid email"
            } else {
                passwordValidationLbl.isHidden = true
            }
            return
        }
        
        if !isPasswordMatch {
            continueButton.isEnabled = false
            if !password.isEmpty {
                passwordValidationLbl.isHidden = false
                validationText = "Passwords do not match"
            } else {
                passwordValidationLbl.isHidden = true
            }
            return
        }
        
        if !isValidPassword {
            continueButton.isEnabled = false
            validationText = "Password must be at least 6 characters"
        }
        passwordValidationLbl.isHidden = true
        continueButton.isEnabled = true
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        view.endEditing(true)
        isSignIn ? handleSignIn() : handleCreateUser()
        defaults.set(rememberMeSwitch.isOn, forKey: K.Defaults.rememberMe)
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        print("reset pw")
    }
    
    func setupUI() {
//        self.navigationItem.largeTitleDisplayMode = .never
        self.title = isSignIn ? "Sign in" : "Sign up"
        continueButton.tintColor = .label
        continueButton.setTitleColor(.systemBackground, for: .normal)
        continueButton.isEnabled = false
        emailLbl.text = "Email"
        passwordLbl.text = "Password"
        confirmPasswordLbl.text = "Confirm password"
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        confirmPasswordTextField.placeholder = "Confirm password"
        confirmPasswordView.isHidden = isSignIn
        resetPasswordButton.isHidden = !isSignIn
        continueButton.setTitle(isSignIn ? "Sign in" : "Sign up", for: .normal)
        passwordValidationLbl.isHidden = true
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        if isSignIn {
            validationLabelToTextFieldConstraint.constant -= confirmPasswordView.frame.height
            rememberMeViewToConfirmViewConstraint.constant -= confirmPasswordView.frame.height
            passwordTextField.returnKeyType = .done
        }
    }
    
    func handleSignIn() {
        ProgressHUD.animationType = .horizontalDotScaling
        ProgressHUD.animate()
        Task {
            let success = await AuthManager.signIn(email: email, password: password, viewController: self)
            if success {
                await FirestoreManager.getData()
                goToHome(isFromSplash: false)
            }
            ProgressHUD.dismiss()
        }
    }
    
    func handleCreateUser() {
        ProgressHUD.animationType = .horizontalDotScaling
        ProgressHUD.colorHUD = .systemGroupedBackground
        ProgressHUD.animate()
        Task {
            let success = await AuthManager.createUser(email: email, password: password, viewController: self)
            if success {
                let homeVC = HomeViewController()
                self.navigationController?.pushViewController(homeVC, animated: true)
//                goToHome(isFromSplash: false)
            }
            ProgressHUD.dismiss()
        }
    }
}

extension SignUpSignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return false
        } else if textField == passwordTextField {
            if isSignIn {
                if !isEmailPasswordEmpty {
                    continueTapped(textField)
                    return true
                }
                return false
            } else {
                confirmPasswordTextField.becomeFirstResponder()
                return false
            }
        } else {
            if !isEmailPasswordEmpty && isPasswordMatch {
                continueTapped(textField)
                return true
            }
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textField = textField as? BaseTextField else { return }
        textField.setWhiteBorder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? BaseTextField else { return }
        textField.removeBorder()
    }
}
