//
//  Toast.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 12/03/2024.
//

import UIKit

class ToastView: UIView {

    var label = UILabel()
    var button = UIButton()
//    @IBOutlet private weak var messageLabel: UILabel!
//    @IBOutlet private weak var button: UIButton!
    
    var callback: (() -> ())?
    
    var message: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }
    
    var buttonText: String {
        get { button.currentTitle ?? "" }
        set { button.setTitle(newValue, for: .normal) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Log.info("init")
        self.addSubviews(label, button)
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 40),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        label.numberOfLines = 0
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

    }
    
    @objc private func buttonTapped() {
        callback?()
    }
}
