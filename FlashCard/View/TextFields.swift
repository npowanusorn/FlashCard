//
//  TextFields.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import UIKit

class BaseTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 10
        return rect
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyles()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyles()
    }

    func applyStyles() {
        self.borderStyle = .none
        self.autocorrectionType = .no
        self.spellCheckingType = .no

        self.layer.cornerRadius = 12.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.0
        self.layer.borderColor = nil
        self.clipsToBounds = false
        self.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.textColor = .label
    }

    func setWhiteBorder() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
    }

    func removeBorder() {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = nil
    }

}

class PasswordTextField: BaseTextField {
    override func applyStyles() {
        super.applyStyles()

        self.textContentType = .oneTimeCode
        self.isSecureTextEntry = true
        let showPasswordImage = UIImage(named: "Show Password")?.withTintColor(.label, renderingMode: .alwaysTemplate).resize(newHeight: 20)
        let hidePasswordImage = UIImage(named: "Hide Password")?.withTintColor(.label, renderingMode: .alwaysTemplate).resize(newHeight: 20)
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.setImage(hidePasswordImage, for: .selected)
        button.setImage(showPasswordImage, for: UIButton.State())
        let rightView = button
        rightView.contentMode = .scaleAspectFit
        rightView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.rightView = rightView
        self.rightViewMode = .always
    }

    @objc
    func buttonTapped(_ button: UIButton) {
        self.isSecureTextEntry.toggle()
        button.isSelected.toggle()
    }

}
