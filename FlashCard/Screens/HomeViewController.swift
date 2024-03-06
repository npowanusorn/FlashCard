//
//  HomeViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import UniformTypeIdentifiers

class HomeViewController: UITableViewController {
    
    var list: [String] = []
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = K.Texts.home
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.homeVCID)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.largeTitleDisplayMode = .always
        list = defaults.object(forKey: K.Defaults.chapterNameList) as? [String] ?? [String]()
    }
    
    @objc func addTapped() {
        let docPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        docPickerController.delegate = self
        docPickerController.allowsMultipleSelection = true
        present(docPickerController, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let json = try? decoder.decode(Chapter.self, from: json) {
            if list.contains(json.title) {
                let alert = UIAlertController(
                    title: K.Texts.error,
                    message: K.Texts.addErrorDuplicate.formatted(string: json.title),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: K.Texts.dismiss, style: .cancel))
                present(alert, animated: true)
                return
            }
            list.append(json.title)
            
            defaults.setValue(list, forKey: K.Defaults.chapterNameList)
            var dict: [String: String] = [:]
            var keyForChapter = [String]()
            for word in json.wordList {
                dict[word.korDef] = word.enDef
                keyForChapter.append(word.korDef)
            }
            defaults.setValue(dict, forKey: json.title)
            defaults.setValue(keyForChapter, forKey: json.title + K.Defaults.chapterNameArrayAppend)
            tableView.reloadData()
        }
    }
}

// MARK: - Table view data source
extension HomeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list.count == 0 {
            self.tableView.setEmptyMessage(K.Texts.emptyLabel)
        } else {
            self.tableView.restore()
        }
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.homeVCID, for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = list[indexPath.row]
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        let wordsVC = WordsListViewController(chapter: list[indexPath.row])
        self.navigationController?.pushViewController(wordsVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        list.remove(at: indexPath.row)
        defaults.set(list, forKey: K.Defaults.chapterNameList)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension HomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            print(url)
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            }
        }
    }
}
