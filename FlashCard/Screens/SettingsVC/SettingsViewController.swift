//
//  SettingsViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 11/03/2024.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        self.navigationItem.largeTitleDisplayMode = .never
        
        tableView.tableFooterView = getTableFooterView()
    }
    
    private func getTableFooterView() -> UIView {
        let logOutView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.attributedTitle = getAttributedString(
            for: "Log out",
            fontSize: 15.0, weight: .bold
        )
        buttonConfiguration.baseBackgroundColor = .systemRed
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.background.strokeWidth = 1.0
        buttonConfiguration.cornerStyle = .large
        let button = BounceButton(configuration: buttonConfiguration)
        button.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        logOutView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.centerXAnchor.constraint(equalTo: logOutView.centerXAnchor, constant: 0).isActive = true
        button.centerYAnchor.constraint(equalTo: logOutView.centerYAnchor, constant: 0).isActive = true
        
        let currentEmail = Auth.auth().currentUser?.email ?? "LocalizedKeys.localAccount.localized"
        let currentEmailLabel = UILabel()
        currentEmailLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        currentEmailLabel.text = currentEmail
        currentEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        logOutView.addSubview(currentEmailLabel)
        
        currentEmailLabel.centerXAnchor.constraint(equalTo: logOutView.centerXAnchor).isActive = true
        currentEmailLabel.topAnchor.constraint(equalTo: logOutView.topAnchor, constant: 0).isActive = true
        
        return logOutView
    }
    
    @objc private func logOutTapped() {
        let alert = UIAlertController.showAlert(with: "Log out?", message: nil, style: .alert, primaryActionName: "Log out", primaryActionStyle: .default, secondaryActionName: "Cancel", secondaryActionStyle: .cancel) {
            self.handleLogOut()
        }
        self.present(alert, animated: true)
    }
    
    private func handleLogOut() {
        UserDefaults.standard.set(false, forKey: K.Defaults.isGoogleSignedIn)
        UserDefaults.standard.set(false, forKey: K.Defaults.rememberMe)
        let success = AuthManager.signOut(viewController: self)
        if success {
            AppCache.shared.shouldWelcomeVCAnimate = false
            let welcomeVC = WelcomeViewController()
            self.navigationController?.viewControllers = [welcomeVC, self]
            self.navigationController?.popToRootViewController(animated: true)
            resetApp()
        }
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = "1"
        cell.contentConfiguration = content
        return cell
    }
}
