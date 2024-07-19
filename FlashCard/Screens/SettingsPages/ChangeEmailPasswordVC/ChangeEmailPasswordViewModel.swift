//
//  ChangeEmailPasswordViewModel.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 19/07/2024.
//

import Foundation

enum AccountModificationType: String, CaseIterable {
    case email = "Email"
    case password = "Password"
}

class ChangeEmailPasswordViewModel {
    var modificationType: AccountModificationType
    
    init(modificationType: AccountModificationType) {
        self.modificationType = modificationType
    }
}
