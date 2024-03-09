//
//  QuizViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 07/03/2024.
//

import UIKit

class QuizViewController: UIViewController {

//    private var quizType: QuizType = .mcq5
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var revealButton: UIButton!
    @IBOutlet weak var bottomLeftButton: UIButton!
    @IBOutlet weak var bottomRightButton: UIButton!
    @IBOutlet weak var mcqView: UICollectionView!
    @IBOutlet weak var answerLabel: UILabel!
    
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
