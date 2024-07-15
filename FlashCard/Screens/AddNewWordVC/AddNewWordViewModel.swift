//
//  AddNewWordViewModel.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 15/07/2024.
//

import Foundation

protocol AddNewWordDelegate {
    func didAddNewWord()
}

class AddNewWordViewModel {
    let chapter: Chapter
    
    var delegate: AddNewWordDelegate
    
    init(chapter: Chapter, delegate: AddNewWordDelegate) {
        self.chapter = chapter
        self.delegate = delegate
    }
}
