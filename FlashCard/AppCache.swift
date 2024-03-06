//
//  AppCache.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

class AppCache {
    static let shared = AppCache()
    
    var chapter = ""
    var listForChapter = [String:String]()
    var keyArrayForChapter = [String()]
}
