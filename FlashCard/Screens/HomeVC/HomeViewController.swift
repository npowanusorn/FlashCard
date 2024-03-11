//
//  HomeViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import UniformTypeIdentifiers

class HomeViewController: UITableViewController {
    
    var list: [String] {
        ChapterManager.shared.getChapters().map({ chapter in
            chapter.title
        })
    }
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

        Log.info(ChapterManager.shared.getChapters())
        self.title = K.Texts.home
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.homeVCID)
        let action1 = UIAction(title: K.Texts.importFromFile, image: UIImage(systemName: K.Image.importFromFile)) { _ in
            self.addTapped()
        }
        let action2 = UIAction(title: K.Texts.create, image: UIImage(systemName: K.Image.plus)) { _ in
            print("create")
        }
        let divider = makeMenu(children: [action1, action2])
        let reviewAction = UIAction(title: K.Texts.review, image: UIImage(systemName: K.Image.book)) { _ in
            let vc = SelectChaptersViewController()
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
        let quizAction = UIAction(title: K.Texts.quiz, image: UIImage(systemName: K.Image.book)) { _ in
            Log.info("QUIZ")
        }
        let divider2 = makeMenu(children: [divider, reviewAction, quizAction])
        let settingsAction = UIAction(title: K.Texts.settings, image: UIImage(systemName: K.Image.gear)) { _ in
            self.openSettings()
        }
        let menu = makeMenu(children: [divider, divider2, settingsAction])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: K.Image.ellipsis), menu: menu)
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.largeTitleDisplayMode = .always

        filteredList = list
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = K.Texts.search
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        setupNotification()
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
                Log.info("list contains \(json.title)")
                let alert = UIAlertController(
                    title: K.Texts.error,
                    message: K.Texts.addErrorDuplicate.formatted(string: json.title),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: K.Texts.dismiss, style: .cancel))
                present(alert, animated: true)
                return
            }
            ChapterManager.shared.addChapter(chapter: json)
            FirestoreManager.writeData(newChapter: json)
            
//            defaults.setValue(list, forKey: K.Defaults.chapterNameList)
//            var dict: [String: String] = [:]
//            var keyForChapter = [String]()
//            for word in json.wordList {
//                dict[word.korDef] = word.enDef
//                keyForChapter.append(word.korDef)
//            }
//            defaults.setValue(dict, forKey: json.title)
//            defaults.setValue(keyForChapter, forKey: json.title + K.Defaults.chapterNameArrayAppend)
            tableView.reloadData()
        } else {
            Log.error("Failed to parse json")
        }
    }
    
    func filterListForSearch(_ search: String) {
        filteredList = list.filter { (chapterName: String) -> Bool in
            return chapterName.lowercased().contains(search.lowercased())
        }
        tableView.reloadData()
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: K.Notifications.selectedChapters, object: nil)
    }
    
    @objc func notificationReceived() {
        AppCache.shared.selectedChapters = AppCache.shared.reviewQuizSelectedChapters
        let reviewVC = ReviewViewController()
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    func openSettings() {
        Log.info("OPEN SETTINGS")
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
        let chapter = isFiltering ? ChapterManager.shared.getChapter(title: filteredList[indexPath.row]) : ChapterManager.shared.getChapter(title: list[indexPath.row])
        content.text = chapter.title
        content.secondaryText = String(chapter.wordList.count)
        content.prefersSideBySideTextAndSecondaryText = true
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        let chapter = isFiltering ? ChapterManager.shared.getChapter(title: filteredList[indexPath.row]) : ChapterManager.shared.getChapter(title: list[indexPath.row])
        AppCache.shared.selectedChapters = [chapter]
//        AppCache.shared.selectedChapters = isFiltering ? [filteredList[indexPath.row]] : [list[indexPath.row]]
        let wordsVC = WordsListViewController()
        self.navigationController?.pushViewController(wordsVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isSearchBarEmpty
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        _ = ChapterManager.shared.removeChapter(at: indexPath.row)
//        list.remove(at: indexPath.row)
//        defaults.set(list, forKey: K.Defaults.chapterNameList)
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