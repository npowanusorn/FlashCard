//
//  QuizViewModel.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 18/07/2024.
//

import Foundation

enum QuizType: String {
//    case mcq5
//    case mcq10
    case blind
    
//    var number: Int {
//        switch self {
//        case .mcq5:
//            5
//        case .mcq10:
//            10
//        case .blind:
//            0
//        }
//    }
}

class QuizViewModel {
    var quizType: QuizType
    var chapters: [Chapter]
    
    init(quizType: QuizType, chapters: [Chapter]) {
        self.quizType = quizType
        self.chapters = chapters
    }
}
