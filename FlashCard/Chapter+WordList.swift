//
//  Chapter+WordList.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

class ChapterManager {
    static let shared = ChapterManager()
    
    private init() {}
    
    private var chapters = [Chapter]()
    
    func addChapter(chapter: Chapter) {
        chapters.append(chapter)
        chapters.sort { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
    
    func getChapters() -> [Chapter] {
        return chapters
    }
    
    func getChapter(at index: Int) -> Chapter {
        return chapters[index]
    }
    
    func getChapter(title: String) -> Chapter {
        return chapters.first { chapter in
            chapter.title == title
        }!
    }
    
    func removeChapter(at index: Int) -> Chapter {
        return chapters.remove(at: index)
    }
    
    func checkTitleDuplicates(title: String) -> Bool {
        for chapter in chapters {
            if chapter.title == title {
                return true
            }
        }
        return false
    }
}

class Chapter: Codable, Equatable {
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        return lhs.title == rhs.title && lhs.wordList == rhs.wordList
    }
    
    init(chapterStruct: ChapterStruct, id: String? = nil) {
        self.title = chapterStruct.title
        self.wordList = chapterStruct.wordList.map({ WordList(wordStruct: $0) })
        self.id = id ?? generateUID()
    }
    
//    init(title: String, wordList: [WordList]) {
//        self.title = title
//        self.wordList = wordList
//    }
//    
//    convenience init(title: String) {
//        self.init(title: title, wordList: [])
//    }
    
    var title: String
    var wordList: [WordList]
    var id: String
    
    func addWord(new: WordList) {
        wordList.append(new)
    }
    
    func deleteWord(at index: Int) -> WordList {
        return wordList.remove(at: index)
    }
    
    func getKeys() -> [String] {
        return wordList.map { $0.korDef }
    }
    
    func getTuple() -> [(kor: String, en: String)] {
        var arr = [(String, String)]()
        for word in wordList {
            arr.append((kor: word.korDef, en: word.enDef))
        }
        return arr
    }    
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
    
    init(wordStruct: WordStruct, id: String? = nil) {
        self.korDef = wordStruct.korDef
        self.enDef = wordStruct.enDef
        self.syn = wordStruct.syn
        self.ant = wordStruct.ant
        self.korExSe = wordStruct.korExSe
        self.enExSe = wordStruct.enExSe
        self.descr = wordStruct.descr
        self.id = id ?? generateUID()
    }
    
    var korDef: String
    var enDef: String
    var syn: String
    var ant: String
    var korExSe: String
    var enExSe: String
    var descr: String
    private var id: String
    
    func getId() -> String { id }
    
//    var korDef: String { _korDef }
//    var enDef: String { _enDef }
//    var syn: String { _syn }
//    var ant: String { _ant }
//    var korExSe: String { _korExSe }
//    var enExSe: String { _enExSe }
//    var descr: String { _descr }
//    var id: String { _id }
    
//    init(korDef: String, enDef: String, syn: String, ant: String, korExSe: String, enExSe: String, descr: String) {
//        self.korDef = korDef
//        self.enDef = enDef
//        self.syn = syn
//        self.ant = ant
//        self.korExSe = korExSe
//        self.enExSe = enExSe
//        self.descr = descr
//        self.id = generateUID()
//    }
    
//    init(korDef: String, enDef: String) {
//        self.init(korDef: korDef, enDef: enDef, syn: "", ant: "", korExSe: "", enExSe: "", descr: "")
//    }
    
//    mutating func edit(korDef: String? = nil,
//              enDef: String? = nil,
//              syn: String? = nil,
//              ant: String? = nil,
//              korExSe: String? = nil,
//              enExSe: String? = nil,
//              descr: String? = nil
//    ) {
//        if let korDef = korDef { self.korDef = korDef }
//        if let enDef = enDef { self.enDef = enDef }
//        if let syn = syn { self.syn = syn }
//        if let ant = ant { self.ant = ant }
//        if let korExSe = korExSe { self.korExSe = korExSe }
//        if let enExSe = enExSe { self.enExSe = enExSe }
//        if let descr = descr { self.descr = descr }
//    }
}

struct ChapterStruct: Codable {
    var title: String
    var wordList: [WordStruct]
}

struct WordStruct: Codable {
    var korDef: String
    var enDef: String
    var syn: String
    var ant: String
    var korExSe: String
    var enExSe: String
    var descr: String
}
