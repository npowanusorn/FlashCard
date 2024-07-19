//
//  AuthManager.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 10/03/2024.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import KeychainSwift
import SwiftyBeaver

// MARK: - AuthManager
class AuthManager {
    static func signIn(with credentials: AuthCredential, viewController: UIViewController? = nil) async -> Bool {
        do {
            Log.info("SIGNING IN WITH CREDENTIALS")
            try await Auth.auth().signIn(with: credentials)
            Log.info("SIGNED IN WITH CREDENTIALS")
            return true
        } catch let error as NSError {
            Log.error("ERROR SIGNING IN: \(error.localizedDescription)")
            if let vc = viewController { FirebaseErrorManager.handleError(error: error, viewController: vc) }
            return false
        }
    }
    
    static func signIn(email: String, password: String, viewController: UIViewController? = nil) async -> Bool {
        do {
            let keychain = KeychainSwift()
            Log.info("SIGNING IN")
            try await Auth.auth().signIn(withEmail: email, password: password)
            keychain.set(email, forKey: K.Keychain.email)
            keychain.set(password, forKey: K.Keychain.password)
            Log.info("SIGNING IN SUCCESS")
            return true
        } catch let error as NSError {
            Log.error("ERROR SIGNING IN: \(error.localizedDescription)")
            if let vc = viewController { FirebaseErrorManager.handleError(error: error, viewController: vc) }
            return false
        }
    }
    
    static func createUser(email: String, password: String, viewController: UIViewController? = nil) async -> Bool {
        do {
            let keychain = KeychainSwift()
            Log.info("CREATE USER")
            try await Auth.auth().createUser(withEmail: email, password: password)
            keychain.set(email, forKey: K.Keychain.email)
            keychain.set(password, forKey: K.Keychain.password)
            Log.info("CREATE USER SUCCESS")
            return true
        } catch let error as NSError {
            Log.error("ERROR CREATE USER: \(error.localizedDescription)")
            if let vc = viewController { FirebaseErrorManager.handleError(error: error, viewController: vc) }
            return false
        }
    }
    
    static func deleteUser(password: String, viewController: UIViewController) async {
        let keychain = KeychainSwift()
        let currentUser = Auth.auth().currentUser
        guard let email = keychain.get(K.Keychain.email) else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            Log.info("**** REAUTHENTICATING ****")
            try await currentUser?.reauthenticate(with: credential)
            Log.info("**** REAUTHENTICATED - STARTING ACCOUNT DELETION ****")
            try await currentUser?.delete()
            Log.info("**** DELETION COMPLETE ****")
            clearAllData()
        } catch let error as NSError {
            Log.error("ERROR DELETING: \(error.localizedDescription)")
            FirebaseErrorManager.handleError(error: error, viewController: viewController)
        }
    }
    
    static func signOut(viewController: UIViewController) -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let error as NSError {
            FirebaseErrorManager.handleError(error: error, viewController: viewController)
            return false
        }
    }
    
    static func changeEmail(newEmail: String, password: String, viewController: UIViewController) async {
        let keychain = KeychainSwift()
        let currentUser = Auth.auth().currentUser
        guard let email = keychain.get(K.Keychain.email) else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            Log.info("**** REAUTHENTICATING ****")
            try await currentUser?.reauthenticate(with: credential)
            Log.info("**** REAUTHENTICATED - CHANGING ACCOUNT EMAIL ****")
            try await Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: newEmail)
            Log.info("**** CHANGE COMPLETE ****")
            clearAllData()
        } catch let error as NSError {
            Log.error("ERROR DELETING: \(error.localizedDescription)")
            FirebaseErrorManager.handleError(error: error, viewController: viewController)
        }
    }
    
    static func changePassword(newPassword: String, oldPassword: String, viewController: UIViewController) async {
        let keychain = KeychainSwift()
        let currentUser = Auth.auth().currentUser
        guard let email = keychain.get(K.Keychain.email) else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        do {
            Log.info("**** REAUTHENTICATING ****")
            try await currentUser?.reauthenticate(with: credential)
            Log.info("**** REAUTHENTICATED - CHANGING ACCOUNT PASSWORD ****")
            try await Auth.auth().currentUser?.updatePassword(to: newPassword)
            Log.info("**** CHANGE COMPLETE ****")
            clearAllData()
        } catch let error as NSError {
            Log.error("ERROR DELETING: \(error.localizedDescription)")
            FirebaseErrorManager.handleError(error: error, viewController: viewController)
        }
    }
}

// MARK: - Firestore
class FirestoreManager {
    static var delegate: FirestoreDelegate?
    private static var allChapterIDs = [String]()
    private static var allWordsIDs: [String] = ChapterManager.shared.getWordListIDs() {
        didSet {
            
        }
    }
    private static var selfChanges: [String] = []
    
    // MARK: - getData
    /// gets all data from Firebase
    static func getData(isFromAppLaunch: Bool) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        Log.info("getData called")
        ChapterManager.shared.removeAll()
        let db = Firestore.firestore()
        let chaptersCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.chapters)
        do {
            addSnapshotListener(collection: chaptersCollection)
            let chaptersSnapshot = try await chaptersCollection.order(by: K.FirestoreKeys.FieldKeys.title).getDocuments()
            let chaptersDocuments = chaptersSnapshot.documents
            for chaptersDocument in chaptersDocuments {
                let title = chaptersDocument.data()[K.FirestoreKeys.FieldKeys.title] as? String ?? ""
                let id = chaptersDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String ?? ""
                allChapterIDs.append(id)
                let newChapter = Chapter(chapterStruct: ChapterStruct(title: title, wordList: []), id: id)
                let wordListCollectionQuery = chaptersCollection
                    .document(chaptersDocument.documentID)
                    .collection(K.FirestoreKeys.CollectionKeys.wordList)
                addSnapshotListener(collection: wordListCollectionQuery, with: chaptersDocument.documentID)
                let wordListSnapshot = try await wordListCollectionQuery.getDocuments()
                let wordListDocuments = wordListSnapshot.documents
                for wordListDocument in wordListDocuments {
                    let korDef = wordListDocument.data()[K.FirestoreKeys.FieldKeys.korDef] as? String ?? ""
                    let enDef = wordListDocument.data()[K.FirestoreKeys.FieldKeys.enDef] as? String ?? ""
                    let syn = wordListDocument.data()[K.FirestoreKeys.FieldKeys.syn] as? String ?? ""
                    let ant = wordListDocument.data()[K.FirestoreKeys.FieldKeys.ant] as? String ?? ""
                    let korExSe = wordListDocument.data()[K.FirestoreKeys.FieldKeys.korExSe] as? String ?? ""
                    let enExSe = wordListDocument.data()[K.FirestoreKeys.FieldKeys.enExSe] as? String ?? ""
                    let descr = wordListDocument.data()[K.FirestoreKeys.FieldKeys.descr] as? String ?? ""
                    let id = wordListDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String ?? generateUID()
                    let newWordStruct = WordStruct(
                        korDef: korDef,
                        enDef: enDef,
                        syn: syn,
                        ant: ant,
                        korExSe: korExSe,
                        enExSe: enExSe,
                        descr: descr
                    )
                    newChapter.addWord(new: WordList(wordStruct: newWordStruct, id: id))
                }
                ChapterManager.shared.addChapter(chapter: newChapter)
                Log.info("chapterIDs: \(ChapterManager.shared.getChapterIDs())")
                Log.info("wordListIDs: \(ChapterManager.shared.getWordListIDs())")
            }
            Log.info("getData finish")
            return
        } catch {
            Log.error("getData error: \(error)")
            return
        }
    }
    
    // MARK: - addSnapshotListener
    /// Adds snapshot listener to the collection to listen for changes
    /// - Parameters:
    ///     - collection: collection to add listener to
    private static func addSnapshotListener(collection: CollectionReference, with id: String? = nil) {
        guard !AppCache.shared.didAddSnapshotListener(for: id ?? collection.collectionID) else { return }
        Log.info("add listener for: \(id ?? collection.collectionID)")
        collection.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                Log.error("Add snapshot error for \(collection.collectionID): \(error?.localizedDescription ?? "")")
                return
            }
            AppCache.shared.addedSnapshotListener(for: id ?? collection.collectionID)
            Log.info("documentChanges: \(querySnapshot.documentChanges.count)")
            Task {
                try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
                main {
                    handleDocumentChanges(changes: querySnapshot.documentChanges)
                }
            }
        }
    }
    
    static private func handleDocumentChanges(changes: [DocumentChange]) {
        changes.forEach { diff in
            let data = diff.document.data()
            let id = data[K.FirestoreKeys.FieldKeys.id] as? String ?? ""
            Log.info("data: \(data)")
            let chapterIDs = ChapterManager.shared.getChapterIDs()
            let wordListIDs = ChapterManager.shared.getWordListIDs()
            Log.info("chapterIDs: \(chapterIDs)")
            Log.info("wordListIDs: \(wordListIDs)")
            switch diff.type {
            case .added:
                if !chapterIDs.contains(id) && !wordListIDs.contains(id) {
                    Log.info("ADDED: \(data)")
                    delegate?.didUpdate()
                }
            case .removed:
                if chapterIDs.contains(id) || wordListIDs.contains(id) {
                    Log.info("REMOVED: \(data)")
                    delegate?.didUpdate()
                }
            case .modified:
                Log.info("MODIFIED: \(data)")
                delegate?.didUpdate()
            }
        }
    }
    
    // MARK: - writeData(newChapter)
    /// adds new chapter to Firebase
    /// - Parameters:
    ///     - newChapter: new chapter to be added
    static func writeData(newChapter: Chapter) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        selfChanges.append(newChapter.id)
        Log.info("writeData called")
        let db = Firestore.firestore()
        let chapterCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.chapters)
        let newDocID = chapterCollection.addDocument(data: [
            K.FirestoreKeys.FieldKeys.title: newChapter.title,
            K.FirestoreKeys.FieldKeys.id: newChapter.id,
            K.FirestoreKeys.FieldKeys.isChapter: true
        ]) { error in
            if let error = error {
                Log.error("ERROR WRITING CHAPTER: \(error)")
            }
        }.documentID
        let wordListCollection = chapterCollection
            .document(newDocID)
            .collection(K.FirestoreKeys.CollectionKeys.wordList)
        for wordList in newChapter.wordList {
            wordListCollection.addDocument(data: [
                K.FirestoreKeys.FieldKeys.korDef: wordList.korDef,
                K.FirestoreKeys.FieldKeys.enDef: wordList.enDef,
                K.FirestoreKeys.FieldKeys.syn: wordList.syn,
                K.FirestoreKeys.FieldKeys.ant: wordList.ant,
                K.FirestoreKeys.FieldKeys.korExSe: wordList.korExSe,
                K.FirestoreKeys.FieldKeys.enExSe: wordList.enExSe,
                K.FirestoreKeys.FieldKeys.descr: wordList.descr,
                K.FirestoreKeys.FieldKeys.id: wordList.getId()
            ]) { error in
                if let error = error {
                    Log.error("ERROR: \(error)")
                }
            }
        }
        Log.info("writeData finish")
    }
    
    // MARK: - writeData(newWord)
    /// adds new word to a chapter
    /// - Parameters:
    ///     - newWord: new word to be added
    ///     - chapter: chapter the word belongs to
    static func writeData(newWord: WordList, for chapter: Chapter) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        Log.info("WRITE WORDLIST: \(newWord.description) FOR CHAPTER: \(chapter.description)")
        selfChanges.append(newWord.getId())
        let db = Firestore.firestore()
        do {
            let chapterCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
                .document(currentUser.uid)
                .collection(K.FirestoreKeys.CollectionKeys.chapters)
            let documentForChapter = try await chapterCollection.getDocuments()
            var correctDocumentID = ""
            documentForChapter.documents.forEach { document in
                let id = document.data()[K.FirestoreKeys.FieldKeys.id] as? String ?? ""
                if id == chapter.id {
                    correctDocumentID = document.documentID
                }
            }
            guard !correctDocumentID.isEmpty else {
                Log.error("unable to find chapter")
                return
            }
            let wordsListCollection = chapterCollection
                .document(correctDocumentID)
                .collection(K.FirestoreKeys.CollectionKeys.wordList)
            wordsListCollection.addDocument(data: [
                K.FirestoreKeys.FieldKeys.korDef: newWord.korDef,
                K.FirestoreKeys.FieldKeys.enDef: newWord.enDef,
                K.FirestoreKeys.FieldKeys.syn: newWord.syn,
                K.FirestoreKeys.FieldKeys.ant: newWord.ant,
                K.FirestoreKeys.FieldKeys.korExSe: newWord.korExSe,
                K.FirestoreKeys.FieldKeys.enExSe: newWord.enExSe,
                K.FirestoreKeys.FieldKeys.descr: newWord.descr,
                K.FirestoreKeys.FieldKeys.id: newWord.getId()
            ]) { error in
                if let error = error {
                    Log.error("ERROR: \(error.localizedDescription)")
                }
            }
            Log.info("WRITE FINISH")
        } catch {
            Log.error("WRITE NEWWORD FAILED")
        }
    }
    
    // MARK: - deleteData
    /// delete chapter from Firebase
    /// - Parameters:
    ///     - chapterIDToDelete: ID of the chapter to be deleted
    static func deleteData(chapterIDToDelete: String) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        Log.info("deleteData called")
        selfChanges.append(chapterIDToDelete)
        let db = Firestore.firestore()
        let chaptersCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.chapters)
        do {
            let chapterDocuments = try await chaptersCollection.getDocuments().documents
            for chapterDocument in chapterDocuments {
                let chapterID = (chapterDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String) ?? ""
                if chapterID == chapterIDToDelete {
                    try await chaptersCollection.document(chapterDocument.documentID).delete()
                }
            }
        } catch {
            Log.error("deleteData error: \(error)")
        }
        Log.info("deleteData finish")
    }
}

// MARK: - FirestoreDelegate
/// delegate protocol to notify change
protocol FirestoreDelegate {
    func didUpdate() -> Void
}

// MARK: - FirebaseErrorManager
class FirebaseErrorManager {
    
    // MARK: - handleError
    /// handle errors returned from Firebase operations
    /// - Parameters:
    ///     - error: The error returned from Firebase operation
    ///     - viewController: ViewController to display error alert
    static func handleError(error: NSError, viewController: UIViewController) {
        var errorMessage = ""
        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else { return }
        Log.error("ERROR: \(errorCode.rawValue)")
        switch errorCode {
        case .emailAlreadyInUse:
            errorMessage = "Email already in use"
        case .userDisabled:
            errorMessage = "Account is disabled"
        case .wrongPassword, .userNotFound, .invalidCredential:
            errorMessage = "Email or password incorrect"
        case .weakPassword:
            errorMessage = "Password must be at least 6 characters long"
        default:
            errorMessage = "Unknown error, try again later. \nError code: \(errorCode.rawValue)"
        }
        let alert = UIAlertController.showErrorAlert(message: errorMessage)
        main { viewController.present(alert, animated: true) }
    }
}
