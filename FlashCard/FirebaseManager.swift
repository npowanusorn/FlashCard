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
            let keychain = KeychainSwift()
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
}

// MARK: - Firestore
class FirestoreManager {
    static func getData() async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let chaptersCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.chapters)
        do {
            let chaptersSnapshot = try await chaptersCollection.order(by: "title").getDocuments()
            let chaptersDocuments = chaptersSnapshot.documents
            for chaptersDocument in chaptersDocuments {
                let title = chaptersDocument.data()[K.FirestoreKeys.FieldKeys.title] as? String ?? ""
                let id = chaptersDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String ?? ""
                let newChapter = Chapter(chapterStruct: ChapterStruct(title: title, wordList: []), id: id)
                let wordListCollectionQuery = chaptersCollection
                    .document(chaptersDocument.documentID)
                    .collection(K.FirestoreKeys.CollectionKeys.wordList)
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
                Log.info(newChapter)
                ChapterManager.shared.addChapter(chapter: newChapter)
            }
        } catch {
            Log.error(error)
        }
    }
    
    static func writeData(newChapter: Chapter) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let chapterCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.chapters)
        let newDocID = chapterCollection.addDocument(data: [
            K.FirestoreKeys.FieldKeys.title : newChapter.title,
            K.FirestoreKeys.FieldKeys.id : newChapter.id
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
                K.FirestoreKeys.FieldKeys.korDef : wordList.korDef,
                K.FirestoreKeys.FieldKeys.enDef : wordList.enDef,
                K.FirestoreKeys.FieldKeys.syn : wordList.syn,
                K.FirestoreKeys.FieldKeys.ant : wordList.ant,
                K.FirestoreKeys.FieldKeys.korExSe : wordList.korExSe,
                K.FirestoreKeys.FieldKeys.enExSe : wordList.enExSe,
                K.FirestoreKeys.FieldKeys.descr : wordList.descr,
            ]) { error in
                if let error = error {
                    Log.error("ERROR: \(error)")
                }
            }
        }
    }
    
    static func deleteData(chapterIDToDelete: String) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let chaptersCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.chapters)
        do {
            let chapterDocuments = try await chaptersCollection.getDocuments().documents
            for chapterDocument in chapterDocuments {
                let chapterID = (chapterDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String) ?? ""
                Log.info(chapterDocument.documentID)
                if chapterID == chapterIDToDelete {
                    try await chaptersCollection.document(chapterDocument.documentID).delete()
                    
                }
            }
        } catch {
            Log.error("ERROR: \(error)")
        }
    }
}

// MARK: - FirebaseErrorManager
class FirebaseErrorManager {
    static func handleError(error: NSError, viewController: UIViewController) {
        var errorMessage = ""
        
        switch error.code {
        case AuthErrorCode.networkError.rawValue:
            errorMessage = "No internet connection available"
        case
            AuthErrorCode.userNotFound.rawValue,
            AuthErrorCode.wrongPassword.rawValue:
            errorMessage = "Email or password is incorrect"
        case AuthErrorCode.userDisabled.rawValue:
            errorMessage = "Account is disabled"
        case AuthErrorCode.weakPassword.rawValue:
            errorMessage = "Password must be at least 6 characters long"
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            errorMessage = "Email already in use. Sign in or use a different email"
        default:
            errorMessage = "Unknown error, try again later. \nError code: \(error.code)"
        }
        let alert = UIAlertController.showErrorAlert(message: errorMessage)
        main { viewController.present(alert, animated: true) }
    }
}
