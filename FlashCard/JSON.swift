//
//  JSON.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

class Chapter: Codable, Equatable {
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        return lhs.title == rhs.title && lhs.wordList == rhs.wordList
    }
    
    var title: String
    var wordList: [WordList]
}

class WordList: Codable, Equatable {
    static func == (lhs: WordList, rhs: WordList) -> Bool {
        return (lhs.korDef == rhs.korDef) &&
        (lhs.enDef == rhs.enDef) && 
        (lhs.syn == rhs.syn) &&
        (lhs.ant == rhs.ant) &&
        (lhs.korExSe == rhs.korExSe) &&
        (lhs.enExSe == rhs.enExSe) &&
        (lhs.descr == rhs.descr)
    }
    
    var korDef: String
    var enDef: String
    var syn: String
    var ant: String
    var korExSe: String
    var enExSe: String
    var descr: String
}
