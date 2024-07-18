//
//  QuizViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 07/03/2024.
//

import UIKit

class QuizViewController: UIViewController {

    private let viewModel: QuizViewModel
    private var questionsArray: [WordList]
    private var currentProgress = -1
    
    @IBOutlet private weak var nonMCQView: UIView!
    @IBOutlet private weak var progressBar: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var wordLabel: UILabel!
    @IBOutlet private weak var revealButton: UIButton!
    @IBOutlet private weak var bottomLeftButton: UIButton!
    @IBOutlet private weak var bottomRightButton: UIButton!
    @IBOutlet private weak var mcqCollectionView: UICollectionView!
    @IBOutlet private weak var answerLabel: UILabel!
    @IBOutlet private weak var bottomButtonsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Quiz"
        setupUI()
        
//        mcqCollectionView.delegate = self
//        mcqCollectionView.dataSource = self
    }
    
    init(viewModel: QuizViewModel) {
        self.viewModel = viewModel
        var array = [WordList]()
        for chapter in self.viewModel.chapters {
            for wordList in chapter.wordList {
                array.append(wordList)
            }
        }
        self.questionsArray = array.shuffled()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        answerLabel.isHidden = true
        updateUIForNextQuestion(moveCurrentToBack: true)
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        answerLabel.isHidden = true
        updateUIForNextQuestion(moveCurrentToBack: false)
    }
    
    @IBAction func revealButtonTapped(_ sender: Any) {
        answerLabel.isHidden = false
    }
    
    private func setupUI() {
        progressBar.progress = 0
        bottomButtonsStackView.isHidden = false
        nonMCQView.isHidden = false
        mcqCollectionView.isHidden = true
        answerLabel.isHidden = true
        bottomLeftButton.setTitle("Wrong", for: .normal)
        bottomRightButton.setTitle("Correct", for: .normal)
        revealButton.setTitle("Reveal", for: .normal)
        updateUIForNextQuestion(moveCurrentToBack: false)
        progressLabel.text = "\(currentProgress)/\(questionsArray.count)"
//        switch viewModel.quizType {
//        case .mcq5, .mcq10:
//            bottomButtonsStackView.isHidden = true
//            nonMCQView.isHidden = true
//            mcqCollectionView.isHidden = false
//        case .blind:
//            bottomButtonsStackView.isHidden = false
//            nonMCQView.isHidden = false
//            mcqCollectionView.isHidden = true
//        }
    }
    
    private func updateUIForNextQuestion(moveCurrentToBack: Bool) {
        if moveCurrentToBack {
            let current = questionsArray.remove(at: currentProgress)
            questionsArray.append(current)
        } else {
            currentProgress += 1
        }
        guard currentProgress < questionsArray.count else {
            let alert = UIAlertController.showAlert(with: "Completed", message: "Quiz completed. End or Retry?", style: .alert, primaryActionName: "End", primaryActionStyle: .default, secondaryActionName: "Retry", secondaryActionStyle: .default) {
                self.navigationController?.popViewController(animated: true)
//                self.dismiss(animated: true) {
//                    self.navigationController?.popViewController(animated: true)
//                }
            } secondaryCompletion: {
                Log.debug("RETRY")
            }
            self.present(alert, animated: true)
            return
        }
        wordLabel.text = questionsArray[currentProgress].korDef
        answerLabel.text = questionsArray[currentProgress].enDef
        progressBar.progress = Float(currentProgress) / Float(questionsArray.count)
    }
    
//    private func setupMCQ() {
//        switch viewModel.quizType {
//        case .mcq5:
//            
//        case .mcq10:
//            <#code#>
//        default:
//            return
//        }
//    }
}

//extension QuizViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        viewModel.quizType.number
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        var content = cell.contentConfiguration
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        Log.info("did select: \(indexPath.row)")
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        switch viewModel.quizType {
//        case .mcq5:
//            return CGSize(width: ScreenSize.width / 2, height: 50)
//        case .mcq10:
//            return CGSize(width: ScreenSize.width / 4, height: 50)
//        case .blind:
//            return CGSize(width: 0, height: 0)
//        }
//    }
//}
