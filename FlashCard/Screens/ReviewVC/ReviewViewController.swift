//
//  ReviewViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import AVFoundation

class ReviewViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var repeatBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var speakerImg: UIImageView!
    
    let defaults = UserDefaults.standard
    var isShuffled = false
    var isAutoSpeak = false
//    var wordsDict = [String:String]()
//    var keysArray = [String]()
//    let dict: [String:[String: String]]
    let selectedChapters: [Chapter]
    var tupleArray: [(kor: String, en: String)] = []
    var shuffledTupleArray: [(kor: String, en: String)] = []
//    var shuffledArray = [String]()
//    var prevItemsStack = Stack()
    let synthesizer = AVSpeechSynthesizer()
    var currentIdx = 0
    var totalCount: Int {
        var count = 0
        for selectedChapter in selectedChapters {
            count += selectedChapter.wordList.count
        }
        return count
    }
    
    var progressLabelText: String {
        get { return progressLabel.text ?? "" }
        set { progressLabel.text = newValue }
    }
    
    var topLabelText: String {
        get { return topLabel.text ?? "" }
        set { topLabel.text = newValue }
    }
    var bottomLabelText: String {
        get { return bottomLabel.text ?? "" }
        set { bottomLabel.text = newValue }
    }
    var selectedSegment: Int {
        segmentedControl.selectedSegmentIndex
    }
    
    init() {
        selectedChapters = AppCache.shared.selectedChapters
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

        self.navigationItem.largeTitleDisplayMode = .never
        for selectedChapter in selectedChapters {
            tupleArray += selectedChapter.getTuple()
        }
        isShuffled = defaults.bool(forKey: K.Defaults.isShuffled)
        isAutoSpeak = defaults.bool(forKey: K.Defaults.isAutoSpeak)
        
        self.title = K.Texts.review
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: K.Image.ellipsis), menu: makeMenu())
        segmentedControl.setTitle(K.Texts.all, forSegmentAt: 0)
        segmentedControl.setTitle(K.Texts.kor, forSegmentAt: 1)
        segmentedControl.setTitle(K.Texts.en, forSegmentAt: 2)
        topView.layer.cornerRadius = 16
        bottomView.layer.cornerRadius = 16
        prevBtn.isEnabled = false
        
        setLabelsWithValues()
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(speak))
        speakerImg.addGestureRecognizer(tap)
        tap = UITapGestureRecognizer(target: self, action: #selector(toggleTopTextFade))
        topView.addGestureRecognizer(tap)
        tap = UITapGestureRecognizer(target: self, action: #selector(toggleBottomTextFade))
        bottomView.addGestureRecognizer(tap)
        
        let cfg = UIImage.SymbolConfiguration(hierarchicalColor: .placeholderText)
        speakerImg.image = UIImage(systemName: K.Image.speakerFilled)?.withRenderingMode(.automatic).applyingSymbolConfiguration(cfg)
    }

    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        let selectedValue = segmentedControl.selectedSegmentIndex
        if selectedValue == 0 {
            topLabel.fadeIn(duration: K.fadeDuration)
            bottomLabel.fadeIn(duration: K.fadeDuration)
        } else if selectedValue == 1 {
            topLabel.fadeIn(duration: K.fadeDuration)
            bottomLabel.fadeOut(duration: K.fadeDuration)
        } else {
            topLabel.fadeOut(duration: K.fadeDuration)
            bottomLabel.fadeIn(duration: K.fadeDuration)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        currentIdx += 1
        setLabelsWithValues()
        updateButtonsIfNeeded()
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        currentIdx -= 1
        setLabelsWithValues()
        updateButtonsIfNeeded()
    }
    
    @IBAction func repeatPressed(_ sender: Any) {
        reset()
    }
        
//    func initializeArrayAndDict() {
//        for chapter in selectedChapters {
//            let arr = defaults.array(forKey: chapter + K.Defaults.chapterNameArrayAppend) as! [String]
//            let dict = defaults.object(forKey: chapter) as! [String:String]
//            for key in arr {
//                let dupKey = key + String(
//                    repeating: K.Texts.dup,
//                    count: keysArray.countStringContainingOccurrences(key)
//                )
//                keysArray.append(dupKey)
//                wordsDict[dupKey] = dict[key]
//            }
//        }
//    }
    
    func updateButtonsIfNeeded() {
        nextBtn.isEnabled = !(currentIdx + 1 == tupleArray.count)
        prevBtn.isEnabled = !(currentIdx == 0)
    }
    
    func setLabelsWithValues() {
        let currentTuple = isShuffled ? shuffledTupleArray[currentIdx] : tupleArray[currentIdx]
        topLabelText = currentTuple.kor
        bottomLabelText = currentTuple.en
//        topLabelText = key.replacingOccurrences(of: K.Texts.dup, with: "")
//        bottomLabelText = wordsDict[key]!
        progressLabelText = "\(currentIdx + 1)/\(totalCount)"
        if selectedSegment == 1 {
            bottomLabel.alpha = 0
        } else if selectedSegment == 2 {
            topLabel.alpha = 0
        }
    }
    
    @objc func speak() {
        let utterance = AVSpeechUtterance(string: topLabelText)
        utterance.voice = AVSpeechSynthesisVoice(language: K.Language.ko)
        synthesizer.speak(utterance)
    }
    
    @objc func toggleTopTextFade() {
        if selectedSegment != 2 {
            return
        }
        if topLabel.alpha == 0 {
            topLabel.fadeIn(duration: K.fadeDuration)
        } else {
            topLabel.fadeOut(duration: K.fadeDuration)
        }
    }
    
    @objc func toggleBottomTextFade() {
        if selectedSegment != 1 {
            return
        }
        if bottomLabel.alpha == 0 {
            bottomLabel.fadeIn(duration: K.fadeDuration)
        } else {
            bottomLabel.fadeOut(duration: K.fadeDuration)
        }
    }
    
    func makeMenu() -> UIMenu {
        let menu = UIMenu(options: .displayInline, children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                let action = UIAction(title: K.Texts.shuffle, image: UIImage(systemName: K.Image.shuffle), state: self!.isShuffled ? .on : .off) { _ in
                    self!.isShuffled.toggle()
                    self!.reset()
                    self!.defaults.set(self!.isShuffled, forKey: K.Defaults.isShuffled)
                }
                completion([action])
            },
//            UIDeferredMenuElement.uncached { [weak self] completion in
//                let action = UIAction(title: K.Texts.isAutoSpeak, image: UIImage(systemName: K.Image.speaker), state: self!.isAutoSpeak ? .on : .off) { _ in
//                    self!.isAutoSpeak.toggle()
//                    self!.defaults.set(self!.isAutoSpeak, forKey: K.Defaults.isAutoSpeak)
//                }
//                completion([action])
//            }
        ])
        return menu
    }
    
    func reset() {
        shuffledTupleArray = self.tupleArray.shuffled()
        currentIdx = 0
        updateButtonsIfNeeded()
        setLabelsWithValues()
    }
}
