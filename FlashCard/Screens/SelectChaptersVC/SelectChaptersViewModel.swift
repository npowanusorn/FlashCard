//
//  SelectChaptersViewModel.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 18/07/2024.
//

import Foundation

enum SelectChapterFor {
    case review
    case quiz
}

protocol SelectChaptersDelegate {
    func didSelectChapter(_ chapters: [Chapter], destination: SelectChapterFor)
}

class SelectChaptersViewModel {
    let selectChapterFor: SelectChapterFor
    let delegate: SelectChaptersDelegate
    init(selectChapterFor: SelectChapterFor, delegate: SelectChaptersDelegate) {
        self.selectChapterFor = selectChapterFor
        self.delegate = delegate
    }
}
