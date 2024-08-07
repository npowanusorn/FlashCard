//
//  AppCache.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation
import GoogleSignIn

class AppCache {
    static let shared = AppCache()
    
    private let defaults = UserDefaults.standard
    private var addedCollectionIDs = [String]()
    
    var selectedChapters = [Chapter]()
    var dictForSelectedChapter = [String:String]()
    var keyArrayForSelectedChapter = [String]()
    var allChapters = [String]()
    var reviewQuizSelectedChapters = [Chapter]()
    var isSignInTapped: Bool?
    var isAppSignedIn: Bool { defaults.bool(forKey: K.Defaults.rememberMe) }
    var isAppGoogleSignedIn: Bool { defaults.bool(forKey: K.Defaults.isGoogleSignedIn)}
    var user: GIDGoogleUser?
    var hasRestoredPreviousGoogleSignIn: Bool = false
    var shouldWelcomeVCAnimate: Bool = true
    var isToastShown: Bool = false
    
    func didAddSnapshotListener(for id: String) -> Bool {
        addedCollectionIDs.contains(id)
    }
    
    func addedSnapshotListener(for id: String) {
//        var newCollectionIDs = addedCollectionIDs
        addedCollectionIDs.append(id)
        Log.info("addedCollectionIDs: \(addedCollectionIDs)")
//        defaults.set(newCollectionIDs, forKey: K.Defaults.addedCollectionsSnapshotID)
    }
}
