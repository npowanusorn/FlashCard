//
//  AccountSettingsViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 19/07/2024.
//

import UIKit
import ProgressHUD

class AccountSettingsViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.accountCell)
    }

}

extension AccountSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.accountCell, for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = SettingsMenu.AccountSettings.allCases[indexPath.row].rawValue
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0, 1:
            let changeAccountViewModel = ChangeEmailPasswordViewModel(modificationType: AccountModificationType.allCases[indexPath.row])
            let changeAccountVC = ChangeEmailPasswordViewController(viewModel: changeAccountViewModel)
            let navVC = UINavigationController(rootViewController: changeAccountVC)
            self.present(navVC, animated: true)
        case 2:
            let textFieldAlert = UIAlertController.showTextFieldAlert(with: "Delete Account", message: "Enter password to delete account", actionTitle: "Delete", isSecureEntry: true) { textField in
                ProgressHUD.animationType = .horizontalDotScaling
                ProgressHUD.animate()
                Task {
                    await AuthManager.deleteUser(password: textField.text ?? "", viewController: self)
                    ProgressHUD.dismiss()
                    AppCache.shared.shouldWelcomeVCAnimate = false
                    let welcomeVC = WelcomeViewController()
                    self.navigationController?.viewControllers = [welcomeVC, self]
                    self.navigationController?.popToRootViewController(animated: true)
                    resetApp()

                }
            }
            self.present(textFieldAlert, animated: true)
        default:
            return
        }
    }
        
}
