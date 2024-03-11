//
//  SelectChaptersViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 06/03/2024.
//

import UIKit

class SelectChaptersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectAllBtn: UIButton!
    
    var allChapters: [Chapter] = []
    var selected: [Chapter] = []
    var defaults = UserDefaults.standard
    private var buttonState: ButtonState = .selectAll {
        didSet {
            updateButtonLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select chapters"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        allChapters = ChapterManager.shared.getChapters()
//        allChapters = defaults.array(forKey: K.Defaults.chapterNameList) as! [String]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.selectChaptersVCID)
        tableView.delegate = self
        tableView.dataSource = self
        
        selectAllBtn.setTitle("Select all", for: .normal)
//        selectAllBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    }

    @IBAction func selectAllTapped(_ sender: Any) {
        switch buttonState {
        case .selectAll:
            selected = allChapters
            buttonState = .deselectAll
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            break
        case .deselectAll:
            selected = []
            buttonState = .selectAll
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            break
        }
        tableView.reloadData()
    }
    
    func updateButtonLabel() {
        if selected.count == allChapters.count {
            selectAllBtn.setTitle("Deselect all", for: .normal)
        } else if selected.isEmpty {
            selectAllBtn.setTitle("Select all", for: .normal)
        }
    }
    
    @objc func cancel() {
        AppCache.shared.reviewQuizSelectedChapters = []
        self.dismiss(animated: true)
    }
    
    @objc func done() {
        AppCache.shared.reviewQuizSelectedChapters = selected       
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: K.Notifications.selectedChapters, object: nil)
        }
    }
}

extension SelectChaptersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allChapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.selectChaptersVCID, for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = allChapters[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = selected.contains(allChapters[indexPath.row]) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selected.contains(allChapters[indexPath.row]) {
            let idx = selected.firstIndex(of: allChapters[indexPath.row])!
            selected.remove(at: idx)
        } else {
            selected.append(allChapters[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        self.navigationItem.rightBarButtonItem?.isEnabled = !selected.isEmpty
        if selected.count == allChapters.count {
            buttonState = .deselectAll
        }
        if selected.isEmpty {
            buttonState = .selectAll
        }
    }
    
}

fileprivate enum ButtonState {
    case selectAll
    case deselectAll
}
