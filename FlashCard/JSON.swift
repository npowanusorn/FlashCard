//
//  JSON.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

struct Chapter: Codable, Equatable {
    var title: String
    var wordList: [WordList]
}

struct WordList: Codable, Equatable {
    var korDef: String
    var enDef: String
    var syn: String
    var ant: String
    var korExSe: String
    var enExSe: String
    var descr: String
}
