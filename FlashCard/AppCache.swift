//
//  AppCache.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

class AppCache {
    static let shared = AppCache()
    
    var selectedChapters = [Chapter]()
    var dictForSelectedChapter = [String:String]()
    var keyArrayForSelectedChapter = [String]()
    var allChapters = [String]()
    var reviewQuizSelectedChapters = [Chapter]()
    var isSignInTapped: Bool?
}
