//
//  WordsViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit

class WordsListViewController: UIViewController {

    let chapter: String
    let defaults = UserDefaults.standard
    var wordsDictArr: [String:String] = [:]
    var keysForChapter = [String()]

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
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
    
    @IBAction func reviewTapped(_ sender: Any) {
        print("review")
    }
    
    @IBAction func quizTapped(_ sender: Any) {
        print("quiz")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = chapter
        self.navigationItem.largeTitleDisplayMode = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.wordsVCID)
        wordsDictArr = defaults.object(forKey: chapter) as? [String: String] ?? [:]
        keysForChapter = defaults.array(forKey: chapter + K.Defaults.chapterNameArrayAppend) as? [String] ?? []
        
        segmentedControl.setTitle(K.Texts.all, forSegmentAt: 0)
        segmentedControl.setTitle(K.Texts.kor, forSegmentAt: 1)
        segmentedControl.setTitle(K.Texts.en, forSegmentAt: 2)
    }
}
    // MARK: - Table view data source

extension WordsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsDictArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.wordsVCID, for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
//        content.textProperties.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
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
