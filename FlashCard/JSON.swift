//
//  JSON.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

struct Chapter: Codable {
    var title: String
    var wordList: [WordList]
}

struct WordList: Codable {
    var korDef: String
    var enDef: String
}
