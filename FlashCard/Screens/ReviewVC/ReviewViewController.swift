//
//  ReviewViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import AVFoundation

class ReviewViewController: UIViewController {

    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var speakerImg: UIImageView!
    @IBOutlet private weak var rightButton: BounceButton!
    @IBOutlet private weak var leftButton: BounceButton!
    @IBOutlet private weak var flashCardView: UIView!
    @IBOutlet private weak var mcqView: UIView!
    @IBOutlet private weak var mcqLabel: UILabel!
    @IBOutlet private var answersButton: [UIButton]!
    @IBOutlet private weak var rightMCQView: UIView!
    @IBOutlet weak var mcqProgressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    private let viewModel: ReviewViewModel
    private let defaults = UserDefaults.standard
    private var type: ReviewType
    private var isShuffled = false
    private var isAutoSpeak = false
    private let selectedChapters: [Chapter]
    private var tupleArray: [(kor: String, en: String)] = []
    private var shuffledTupleArray: [(kor: String, en: String)] = []
    private var answerChoicesArray = [String]()
    private let synthesizer = AVSpeechSynthesizer()
    private var currentIdx = 0
    private var correctCount = 0
    private var isQuestionCorrect = true
    private var dontKnowSet = Set<String>()
    private var totalCount: Int {
        var count = 0
        for selectedChapter in selectedChapters {
            count += selectedChapter.wordList.count
        }
        return count
    }
    
    private var progressLabelText: String {
        get { return progressLabel.text ?? "" }
        set { progressLabel.text = newValue }
    }
    
    private var topLabelText: String {
        get { return topLabel.text ?? "" }
        set { topLabel.text = newValue }
    }
    private var bottomLabelText: String {
        get { return bottomLabel.text ?? "" }
        set { bottomLabel.text = newValue }
    }
    private var selectedSegment: Int {
        get { return segmentedControl.selectedSegmentIndex }
        set { segmentedControl.selectedSegmentIndex = newValue }
    }
    
    init(viewModel: ReviewViewModel) {
        self.viewModel = viewModel
        self.selectedChapters = viewModel.chapters
        type = ReviewType(rawValue: defaults.integer(forKey: K.Defaults.questionType)) ?? .flashcard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedChapters.isEmpty {
            fatalError()
        }
                
        for selectedChapter in selectedChapters {
            tupleArray += selectedChapter.getTuple()
        }
        shuffledTupleArray = tupleArray.shuffled()
        isShuffled = defaults.bool(forKey: K.Defaults.isShuffled)
        isAutoSpeak = defaults.bool(forKey: K.Defaults.isAutoSpeak)
        setupCommonUI()
    }

    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        let selectedValue = segmentedControl.selectedSegmentIndex
        defaults.set(selectedValue, forKey: K.Defaults.reviewSelectedSegment)
        UIView.animate(withDuration: K.fadeDuration) {
            self.topLabel.alpha = 0
            self.bottomLabel.alpha = 0
            self.speakerImg.alpha = 0
        } completion: { _ in
            self.reset()
            if selectedValue == 0 {
                self.topLabel.fadeIn(duration: K.fadeDuration)
                self.speakerImg.fadeIn(duration: K.fadeDuration)
            } else {
                self.bottomLabel.fadeIn(duration: K.fadeDuration)
            }
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        currentIdx += 1
        var question: String
        if selectedSegment == 0 {
            question = topLabelText
        } else {
            question = bottomLabelText
        }
        if !dontKnowSet.contains(question) { correctCount += 1 }
        setLabelsWithValues()
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        if selectedSegment == 0 {
            dontKnowSet.insert(topLabelText)
        } else {
            dontKnowSet.insert(bottomLabelText)
        }
        if isShuffled {
            shuffledTupleArray.append(shuffledTupleArray.remove(at: currentIdx))
        } else {
            tupleArray.append(tupleArray.remove(at: currentIdx))
        }
        setLabelsWithValues()
    }
    
    @IBAction func repeatPressed(_ sender: Any) {
        reset()
    }
    
    @IBAction func mcqAnswerButtonPressed(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        guard let answerText = button.titleLabel?.text else { return }
        Log.info(answerText)
        let currentTuple = isShuffled ? shuffledTupleArray[currentIdx] : tupleArray[currentIdx]
        let correctAnswer = selectedSegment == 0 ? currentTuple.en : currentTuple.kor
        if answerText == correctAnswer {
            currentIdx += 1
            if isQuestionCorrect { correctCount += 1 }
            setLabelsWithValues()
        } else {
            isQuestionCorrect = false
            button.isEnabled = false
            button.configuration?.baseBackgroundColor = .red
            setCorrectAnswerLabel(selected: answerText)
        }
    }
    
    func setCorrectAnswerLabel(selected: String) {
        var text = ""
        if selectedSegment == 0 {
            let korDef = tupleArray.first(where: { tuple in
                return tuple.en == selected
            })!.kor
            text = "\(korDef) - \(selected)"
        } else {
            let enDef = tupleArray.first(where: { tuple in
                return tuple.kor == selected
            })!.en
            text = "\(selected) - \(enDef)"
        }
        mcqProgressLabel.text = text
    }
    
    func setupCommonUI() {
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = K.Texts.review
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: K.Image.ellipsis.safeUIImage, menu: makeMenu())
        
        rightButton.setTitle("I know", for: .normal)
        rightButton.setImage(nil, for: .normal)
        leftButton.setTitle("I don't know", for: .normal)
        leftButton.setImage(nil, for: .normal)
        for button in answersButton {
//            button.setTitle(String(button.tag), for: .normal)
            button.titleLabel?.textAlignment = .center
//            button.setAttributedTitle(getAttributedString(for: String(button.tag), fontSize: 24, weight: .bold), for: .normal)
//            button.titleLabel?.adjustsFontSizeToFitWidth = true
//            button.titleLabel?.minimumScaleFactor = 0.1
        }
        
        mcqProgressLabel.text = ""
        progressView.progress = 0
        
        selectedSegment = defaults.integer(forKey: K.Defaults.reviewSelectedSegment)
        segmentedControl.setTitle(K.Texts.kor, forSegmentAt: 0)
        segmentedControl.setTitle(K.Texts.en, forSegmentAt: 1)
        
        switch type {
        case .flashcard:
            setUIForFlash()
        case .mcq:
            setUIForMCQ()
        }
        setLabelsWithValues()
    }
        
    func setLabelsWithValues() {
        guard currentIdx < tupleArray.count else {
            let alert = UIAlertController(title: "Complete", message: "Score: \(correctCount)/\(tupleArray.count)", preferredStyle: .alert)
            let exitAction = UIAlertAction(title: "Exit", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.reset()
            }
            alert.addActions([retryAction, exitAction])
            self.present(alert, animated: true)
            return
        }
        switch type {
        case .flashcard:
            let currentTuple = isShuffled ? shuffledTupleArray[currentIdx] : tupleArray[currentIdx]
            topLabelText = currentTuple.kor
            bottomLabelText = currentTuple.en
            progressLabelText = "\(currentIdx + 1)/\(totalCount)"
            if selectedSegment == 0 {
                bottomLabel.alpha = 0
            } else if selectedSegment == 1 {
                topLabel.alpha = 0
                speakerImg.alpha = 0
            }
        case .mcq:
            answerChoicesArray.removeAll()
            isQuestionCorrect = true
            progressView.setProgress(Float(currentIdx)/Float(tupleArray.count), animated: true)
            let currentArr = isShuffled ? shuffledTupleArray : tupleArray
            let currentTuple = currentArr[currentIdx]
            mcqLabel.text = selectedSegment == 0 ? currentTuple.kor : currentTuple.en
            mcqProgressLabel.text = nil
            let correctChoice = selectedSegment == 0 ? currentTuple.en : currentTuple.kor
            var answersArray = [String]()
            tupleArray.forEach({
                answersArray.append(selectedSegment == 0 ? $0.en : $0.kor)
            })
            let uniqueAnswersSet = Set(answersArray)
            if uniqueAnswersSet.count <= 10 {
                uniqueAnswersSet.forEach { answerChoicesArray.append($0) }
            } else {
                answerChoicesArray.append(correctChoice)
                for _ in 0..<9 {
                    var randAnswer = uniqueAnswersSet.randomElement()!
                    while answerChoicesArray.contains(randAnswer) {
                        randAnswer = uniqueAnswersSet.randomElement()!
                    }
                    answerChoicesArray.append(randAnswer)
                }
            }
            while answerChoicesArray.count != 10 {
                answerChoicesArray.append("")
            }
            answerChoicesArray.shuffle()
            for button in answersButton {
                let title = answerChoicesArray[button.tag]
                button.setAttributedTitle(getAttributedString(for: title, fontSize: Constants.choiceFontSize, weight: .bold), for: .normal)
                button.configuration?.baseBackgroundColor = nil
                button.isEnabled = !title.isEmpty
            }
        }
    }
        
    func setUIForMCQ() {
        flashCardView.isHidden = true
        mcqView.isHidden = false
        mcqLabel.font = UIFont.systemFont(ofSize: Constants.questionFontSize, weight: .bold)
        reset()
    }
    
    func setUIForFlash() {
        flashCardView.isHidden = false
        mcqView.isHidden = true
        
        topView.layer.cornerRadius = 16
        bottomView.layer.cornerRadius = 16
                
        var tap = UITapGestureRecognizer(target: self, action: #selector(speak))
        speakerImg.addGestureRecognizer(tap)
        tap = UITapGestureRecognizer(target: self, action: #selector(toggleTopTextFade))
        topView.addGestureRecognizer(tap)
        tap = UITapGestureRecognizer(target: self, action: #selector(toggleBottomTextFade))
        bottomView.addGestureRecognizer(tap)
        
        let cfg = UIImage.SymbolConfiguration(hierarchicalColor: .placeholderText)
        speakerImg.image = K.Image.speakerFilled.safeUIImage.withRenderingMode(.automatic).applyingSymbolConfiguration(cfg)
        reset()
    }
    
    @objc func speak() {
        let utterance = AVSpeechUtterance(string: topLabelText)
        utterance.voice = AVSpeechSynthesisVoice(language: K.Language.ko)
        synthesizer.speak(utterance)
    }
    
    @objc func toggleTopTextFade() {
        guard selectedSegment == 1 else { return }
        if topLabel.alpha == 0 {
            topLabel.fadeIn(duration: K.fadeDuration)
            speakerImg.fadeIn(duration: K.fadeDuration)
        } else {
            topLabel.fadeOut(duration: K.fadeDuration)
            speakerImg.fadeOut(duration: K.fadeDuration)
        }
    }
    
    @objc func toggleBottomTextFade() {
        guard selectedSegment == 0 else { return }
        if bottomLabel.alpha == 0 {
            bottomLabel.fadeIn(duration: K.fadeDuration)
        } else {
            bottomLabel.fadeOut(duration: K.fadeDuration)
        }
    }
    
    func makeMenu() -> UIMenu {
        let menu = UIMenu(options: .displayInline, children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                let action = UIAction(title: K.Texts.shuffle, image: K.Image.shuffle.safeUIImage, state: self!.isShuffled ? .on : .off) { _ in
                    self!.isShuffled.toggle()
                    self!.reset()
                    self!.defaults.set(self!.isShuffled, forKey: K.Defaults.isShuffled)
                }
                completion([action])
            },
            UIMenu(title: "Type", children: [
                UIDeferredMenuElement.uncached { [weak self] completion in
                    let action = UIAction(title: "Flashcard", image: nil, state: self!.type == .flashcard ? .on : .off) { _ in
                        self!.type = .flashcard
                        self!.defaults.set(self!.type.rawValue, forKey: K.Defaults.questionType)
                        self!.setUIForFlash()
                    }
                    completion([action])
                },
                UIDeferredMenuElement.uncached { [weak self] completion in
                    let action = UIAction(title: "MCQ", image: nil, state: self!.type == .mcq ? .on : .off) { _ in
                        self!.type = .mcq
                        self!.defaults.set(self!.type.rawValue, forKey: K.Defaults.questionType)
                        self!.setUIForMCQ()
                    }
                    completion([action])
                }
            ])
        ])
        return menu
    }
    
    func reset() {
        shuffledTupleArray = self.tupleArray.shuffled()
        currentIdx = 0
        progressView.setProgress(0, animated: true)
        answerChoicesArray.removeAll()
        dontKnowSet.removeAll()
        setLabelsWithValues()
        correctCount = 0
    }
}

private extension ReviewViewController {
    enum ReviewType: Int {
        case flashcard
        case mcq
    }
}

private enum Constants {
    static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    static let choiceFontSize: CGFloat = isPad ? 24 : 18
    static let questionFontSize: CGFloat = isPad ? 36 : 30
}
