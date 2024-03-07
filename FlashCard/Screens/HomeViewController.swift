//
//  HomeViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import UniformTypeIdentifiers

class HomeViewController: UITableViewController {
    
    var list = [String]()
    var filteredList = [String]()
    let defaults = UserDefaults.standard
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = K.Texts.home
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.homeVCID)
        let action1 = UIAction(title: "Add from file", image: UIImage(systemName: "doc.fill")) { _ in
            self.addTapped()
        }
        let action2 = UIAction(title: "Create", image: UIImage(systemName: "plus")) { _ in
            print("create")
        }
        let menu = makeMenu(children: [action1, action2])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), menu: menu)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.largeTitleDisplayMode = .always
        list = defaults.object(forKey: K.Defaults.chapterNameList) as? [String] ?? [String]()
        filteredList = list
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
            list.sort(using: .localizedStandard)
            
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
    
    func filterListForSearch(_ search: String) {
        filteredList = list.filter { (chapterName: String) -> Bool in
            return chapterName.lowercased().contains(search.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - Table view data source
extension HomeViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            if filteredList.count == 0 {
                self.tableView.setEmptyMessage(K.Texts.emptySearch.formatted(string: searchController.searchBar.text ?? ""))
                self.navigationItem.leftBarButtonItem?.isEnabled = false
            } else {
                self.tableView.restore()
                searchController.searchBar.isHidden = false
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }
            return filteredList.count
        } else {
            if list.count == 0 {
                self.tableView.setEmptyMessage(K.Texts.emptyLabel)
                searchController.searchBar.isHidden = true
                self.navigationItem.leftBarButtonItem?.isEnabled = false
            } else {
                self.tableView.restore()
                searchController.searchBar.isHidden = false
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }
            return list.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.homeVCID, for: indexPath)
        var content = UIListContentConfiguration.cell()
        if isFiltering {
            content.text = filteredList[indexPath.row]
        } else {
            content.text = list[indexPath.row]
        }
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        var selectedChapter = isFiltering ? filteredList[indexPath.row] : list[indexPath.row]
        let wordsVC = WordsListViewController(chapter: selectedChapter)
        self.navigationController?.pushViewController(wordsVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isSearchBarEmpty
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

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterListForSearch(searchText)
    }
}
