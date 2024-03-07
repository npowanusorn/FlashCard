//
//  WordsViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import SwiftUI

class WordsListViewController: UIViewController {

    let chapter: String
    let defaults = UserDefaults.standard
    var wordsDictArr = [String:String]()
    var keysForChapter = [String()]
    let segmentedControl = UISegmentedControl()

    @IBOutlet weak var reviewBtn: UIButton!
    @IBOutlet weak var quizBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    init(chapter: String) {
        self.chapter = chapter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func segmentedControlDidChange(_ sender: Any) {
        tableView.reloadData()
    }
    
    @objc func segmentedControlChanged() {
        tableView.reloadData()
    }
    
    @IBAction func reviewTapped(_ sender: Any) {
        AppCache.shared.listForChapter = wordsDictArr
        AppCache.shared.keyArrayForChapter = keysForChapter
        let reviewVC = ReviewViewController()
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    @IBAction func quizTapped(_ sender: Any) {
        print("quiz")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = chapter
        self.navigationItem.largeTitleDisplayMode = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.wordsVCID)
        wordsDictArr = defaults.object(forKey: chapter) as? [String: String] ?? [:]
        keysForChapter = defaults.array(forKey: chapter + K.Defaults.chapterNameArrayAppend) as? [String] ?? []
        segmentedControl.insertSegment(withTitle: K.Texts.all, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: K.Texts.kor, at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: K.Texts.en, at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
//        seg.sizeToFit()
        self.navigationItem.titleView = segmentedControl
        if keysForChapter.isEmpty {
            reviewBtn.isEnabled = false
            quizBtn.isEnabled = false
        }
        
        let action1 = UIAction(title: "Review") { _ in
            AppCache.shared.listForChapter = self.wordsDictArr
            AppCache.shared.keyArrayForChapter = self.keysForChapter
            let reviewVC = ReviewViewController()
            self.navigationController?.pushViewController(reviewVC, animated: true)
        }
        let action2 = UIAction(title: "Quiz") { _ in
//            AppCache.shared.listForChapter = self.wordsDictArr
//            AppCache.shared.keyArrayForChapter = self.keysForChapter
//            let reviewVC = ReviewViewController()
//            self.navigationController?.pushViewController(reviewVC, animated: true)
        }
        let menu = UIMenu(options: .displayInline, children: [action1, action2])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "book.pages.fill"), menu: menu)
        buttonsStackView.isHidden = true
//        let screenSize = UIScreen.main.bounds.size
//        let gradientView = UIView(frame: CGRect(x: 0, y: screenSize.height - 100, width: screenSize.width, height: 100))
//        gradientView.backgroundColor = .black
//        let gradient = CAGradientLayer()
//        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradient.endPoint = CGPoint(x: 0.5, y: 1)
//        let blackColor = UIColor.black
//        gradient.colors = [blackColor.withAlphaComponent(0.0).cgColor, blackColor.withAlphaComponent(0.7).cgColor, blackColor.withAlphaComponent(1.0).cgColor]
//        gradient.locations = [NSNumber(value: 0.0), NSNumber(value: 0.6), NSNumber(value: 1.0)]
//        gradient.frame = gradientView.bounds
//        gradientView.layer.mask = gradient
//        self.view.addSubview(gradientView)
//        self.view.bringSubviewToFront(buttonsStackView)
    }
}
    // MARK: - Table view data source

extension WordsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsDictArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.wordsVCID, for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        content.prefersSideBySideTextAndSecondaryText = true
        content.text = keysForChapter[indexPath.row]
        content.secondaryText = wordsDictArr[keysForChapter[indexPath.row]]
        if segmentedControl.selectedSegmentIndex == 1 {
            content.secondaryTextProperties.color = UIColor.label.withAlphaComponent(0)
        } else if segmentedControl.selectedSegmentIndex == 2 {
            content.textProperties.color = UIColor.label.withAlphaComponent(0)
        }
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}
