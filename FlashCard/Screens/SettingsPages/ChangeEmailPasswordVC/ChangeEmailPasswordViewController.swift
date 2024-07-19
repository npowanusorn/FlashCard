//
//  ChangeEmailPasswordViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 19/07/2024.
//

import UIKit
import ProgressHUD

class ChangeEmailPasswordViewController: UIViewController {

    private let viewModel: ChangeEmailPasswordViewModel
    
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var middleLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var topTextField: BaseTextField!
    @IBOutlet private weak var middleTextField: BaseTextField!
    @IBOutlet private weak var bottomTextField: BaseTextField!
    @IBOutlet private weak var validationLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    
    private var topText: String {
        get { topLabel.text ?? "" }
        set { topLabel.text = newValue }
    }
    private var middleText: String {
        get { middleLabel.text ?? "" }
        set { middleLabel.text = newValue }
    }
    private var bottomText: String {
        get { bottomLabel.text ?? "" }
        set { bottomLabel.text = newValue }
    }
    private var validationText: String {
        get { validationLabel.text ?? "" }
        set { validationLabel.text = newValue }
    }
    private var topTextFieldText: String { topTextField.text ?? "" }
    private var middleTextFieldText: String { middleTextField.text ?? "" }
    private var bottomTextFieldText: String { bottomTextField.text ?? "" }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    init(viewModel: ChangeEmailPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction private func confirmTapped(_ sender: Any) {
        ProgressHUD.animationType = .horizontalDotScaling
        ProgressHUD.animate()
        Task {
            switch self.viewModel.modificationType {
            case .email:
                await AuthManager.changeEmail(newEmail: topTextFieldText, password: bottomTextFieldText, viewController: self)
            case .password:
                await AuthManager.changePassword(newPassword: middleTextFieldText, oldPassword: topTextFieldText, viewController: self)
            }
            ProgressHUD.dismiss()
            self.dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        title = "Change \(viewModel.modificationType.rawValue)"
        topTextField.layer.cornerRadius = 8
        middleTextField.layer.cornerRadius = 8
        bottomTextField.layer.cornerRadius = 8
        validationText = ""
        confirmButton.setTitle("Change \(viewModel.modificationType.rawValue)", for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.clipsToBounds = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.5
        topTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        middleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        bottomTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        switch viewModel.modificationType {
        case .email:
            topText = "New Email"
            middleText = "Confirm New Email"
            bottomText = "Enter Password"
        case .password:
            topText = "Old Password"
            topTextField.isSecureTextEntry = true
            middleText = "New Password"
            middleTextField.isSecureTextEntry = true
            bottomText = "Confirm New Password"
        }
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.5
        guard !(topTextFieldText.isEmpty || middleTextFieldText.isEmpty || bottomTextFieldText.isEmpty) else { return }
        switch viewModel.modificationType {
        case .email:
            guard Validator.isValidEmail(topTextFieldText) else {
                validationText = "Invalid email"
                return
            }
            guard topTextFieldText == middleTextFieldText else {
                validationText = "Email mismatch"
                return
            }
            guard Validator.isValidPassword(bottomTextFieldText) else {
                validationText = "Password must be at least 6 characters"
                return
            }
        case .password:
            guard Validator.isValidPassword(middleTextFieldText) && Validator.isValidPassword(topTextFieldText) else {
                validationText = "Password must be at least 6 characters"
                return
            }
            guard bottomTextFieldText == middleTextFieldText else {
                validationText = "Password mismatch"
                return
            }
        }
        validationText = ""
        confirmButton.isEnabled = true
        confirmButton.alpha = 1
    }
    
}
