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
    
    let wordsDict = AppCache.shared.listForChapter
    var keysArray = AppCache.shared.keyArrayForChapter
    var prevItemsStack = Stack()
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if wordsDict.isEmpty || keysArray.isEmpty || wordsDict.count != keysArray.count {
            fatalError()
        }
        self.title = K.Texts.review
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
        setLabelsWithValues()
        if keysArray.isEmpty {
            nextBtn.isEnabled = false
        }
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func repeatPressed(_ sender: Any) {
        keysArray = AppCache.shared.keyArrayForChapter
    }
    
    func getRandomKeyAndRemoveFromArray() -> String {
        let randomIdx = keysArray.indices.randomElement()!
        let value = keysArray.remove(at: randomIdx)
        return value
    }
    
    func setLabelsWithValues() {
        let key = getRandomKeyAndRemoveFromArray()
        topLabel.text = key
        bottomLabel.text = wordsDict[key]
        prevItemsStack.push(key)
    }
    
    @objc func topViewTapped() {
        let utterance = AVSpeechUtterance(string: topLabel.text!)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko")
        synthesizer.speak(utterance)
    }
}
