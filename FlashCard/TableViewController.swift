//
//  TableViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit

class TableViewController: UITableViewController {
    
    let chapter: String
    let defaults = UserDefaults.standard
    var wordsDictArr: [String:String] = [:]
    
    init(chapter: String) {
        self.chapter = chapter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = chapter
        self.navigationItem.largeTitleDisplayMode = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "wordsCell")
        let dicts = defaults.object(forKey: chapter) as? [String: String] ?? [:]
        wordsDictArr = dicts
        addSegmentElement()
    }
    
    func addSegmentElement() {
        var elem = UISegmentedControl(items: ["1", "2", "3"])
        let screenSize = UIScreen.main.bounds.size
        elem.frame = CGRect(x: 20, y: 20, width: screenSize.width - 40, height: 30)
        elem.selectedSegmentIndex = 0
        elem.layer.opacity = 1
        elem.isOpaque = true
        self.navigationController?.visibleViewController?.view.addSubview(elem)
        elem.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            elem.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            elem.widthAnchor.constraint(equalToConstant: screenSize.width - 40),
            elem.heightAnchor.constraint(equalToConstant: 30),
            elem.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
}
    // MARK: - Table view data source

extension TableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsDictArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordsCell", for: indexPath)
        var content = UIListContentConfiguration.cell()
        let key = Array(wordsDictArr.keys)[indexPath.row]
        content.text = key
        content.secondaryText = wordsDictArr[key]
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        content.prefersSideBySideTextAndSecondaryText = true
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}
