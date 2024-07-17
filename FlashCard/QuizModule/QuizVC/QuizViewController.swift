//
//  QuizViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 07/03/2024.
//

import UIKit

class QuizViewController: UIViewController {

//    private var quizType: QuizType = .mcq5
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var wordLabel: UILabel!
    @IBOutlet private weak var revealButton: UIButton!
    @IBOutlet private weak var bottomLeftButton: UIButton!
    @IBOutlet private weak var bottomRightButton: UIButton!
    @IBOutlet private weak var mcqView: UICollectionView!
    @IBOutlet private weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Quiz"
        mcqView.isHidden = true
    }
    
}

private enum QuizType {
    case mcq5
    case mcq10
    case other
}
