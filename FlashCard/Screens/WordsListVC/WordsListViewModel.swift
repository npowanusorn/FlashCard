//
//  WordsListViewModel.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 15/07/2024.
//

import Foundation

protocol WordsListDelegate {
    func didAddNewWord()
}

class WordsListViewModel {
    let chapter: Chapter
    let delegate: WordsListDelegate
    
    init(chapter: Chapter, delegate: WordsListDelegate) {
        self.chapter = chapter
        self.delegate = delegate
    }
}
