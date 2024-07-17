//
//  SettingsViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 11/03/2024.
//

import UIKit
import FirebaseAuth
import SnapKit

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
        let currentEmail = Auth.auth().currentUser?.email ?? "Unknown email"
        let currentEmailLabel = UILabel()
        currentEmailLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        currentEmailLabel.text = "\(currentEmail)\n\nuid: \(Auth.auth().currentUser?.uid ?? "Unknown uid")"
        currentEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        currentEmailLabel.numberOfLines = 0
        currentEmailLabel.textAlignment = .center
        logOutView.addSubview(currentEmailLabel)
        
        currentEmailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.attributedTitle = getAttributedString(
            for: "Log out",
            fontSize: 15.0, weight: .bold
        )
        buttonConfiguration.baseBackgroundColor = .systemRed
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.background.strokeWidth = 1.0
        buttonConfiguration.cornerStyle = .large
        let button = UIButton(configuration: buttonConfiguration)
        button.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        logOutView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(40)
            make.top.equalTo(currentEmailLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }

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
