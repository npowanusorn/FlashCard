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
    let wordsDict = AppCache.shared.listForChapter
    let keysArray = AppCache.shared.keyArrayForChapter
    var shuffledArray = [String]()
    var prevItemsStack = Stack()
    let synthesizer = AVSpeechSynthesizer()
    var currentIdx = 0
    var totalCount: Int {
        return wordsDict.count
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if wordsDict.isEmpty || keysArray.isEmpty || wordsDict.count != keysArray.count {
            fatalError()
        }
        shuffledArray = keysArray.shuffled()
        isShuffled = defaults.bool(forKey: K.Defaults.isShuffled)
        
        self.title = K.Texts.review
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), menu: makeMenu())
        segmentedControl.setTitle(K.Texts.all, forSegmentAt: 0)
        segmentedControl.setTitle(K.Texts.kor, forSegmentAt: 1)
        segmentedControl.setTitle(K.Texts.en, forSegmentAt: 2)
        topView.layer.cornerRadius = 16
        bottomView.layer.cornerRadius = 16
        prevBtn.isEnabled = false
        repeatBtn.alpha = 0
        
        setLabelsWithValues()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(topViewTapped))
        topView.addGestureRecognizer(tap)
        
        let cfg = UIImage.SymbolConfiguration(hierarchicalColor: .placeholderText)
        speakerImg.image = UIImage(systemName: "speaker.wave.2.circle.fill")?.withRenderingMode(.automatic).applyingSymbolConfiguration(cfg)
    }

    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        let selectedValue = segmentedControl.selectedSegmentIndex
        if selectedValue == 0 {
            topView.alpha = 1
            bottomView.alpha = 1
        } else if selectedValue == 1 {
            topView.alpha = 1
            bottomView.alpha = 0
        } else {
            topView.alpha = 0
            bottomView.alpha = 1
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
    
    func updateButtonsIfNeeded() {
        nextBtn.isEnabled = !(currentIdx + 1 == keysArray.count)
        repeatBtn.alpha = nextBtn.isEnabled ? 0 : 1
        prevBtn.isEnabled = !(currentIdx == 0)
    }
    
    func setLabelsWithValues() {
        let key = isShuffled ? shuffledArray[currentIdx] : keysArray[currentIdx]
        topLabelText = key
        bottomLabelText = wordsDict[key]!
        progressLabelText = "\(currentIdx + 1)/\(totalCount)"
    }
    
    @objc func topViewTapped() {
        let utterance = AVSpeechUtterance(string: topLabel.text!)
        utterance.voice = AVSpeechSynthesisVoice(language: K.Language.ko)
        synthesizer.speak(utterance)
    }
    
    func makeMenu() -> UIMenu {
        let menu = UIMenu(options: .displayInline, children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                let action = UIAction(title: "Shuffle", image: UIImage(systemName: "shuffle"), state: self!.isShuffled ? .on : .off) { _ in
                    self!.isShuffled.toggle()
                    self!.reset()
                    self!.defaults.set(self!.isShuffled, forKey: K.Defaults.isShuffled)
                }
                completion([action])
            }
        ])
        return menu
    }
    
    func reset() {
        shuffledArray = self.keysArray.shuffled()
        currentIdx = 0
        updateButtonsIfNeeded()
        setLabelsWithValues()
    }
}
