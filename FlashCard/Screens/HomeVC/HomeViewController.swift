//
//  HomeViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import UniformTypeIdentifiers
import ProgressHUD
import Toast

class HomeViewController: UITableViewController {
    
    var list: [String] {
        ChapterManager.shared.getChapters().map({ chapter in
            chapter.title
        })
    }
    var filteredList = [String]()
    let defaults = UserDefaults.standard
    let searchController = UISearchController(searchResultsController: nil)
//    let refreshControl = UIRefreshControl()
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var toast: Toast?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirestoreManager.delegate = self
        self.title = K.Texts.home
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.homeVCID)
        self.tableView.alwaysBounceVertical = true
        let importFromFileAction = UIAction(title: K.Texts.importFromFile, image: K.Image.importFromFile.safeUIImage) { _ in
            self.addTapped()
        }
        let createAction = UIAction(title: K.Texts.create, image: K.Image.plus.safeUIImage) { _ in
            let alert = UIAlertController.showTextFieldAlert(with: "New Chapter", message: "Enter the name for the new chapter", actionTitle: "Create") { textField in
                self.createNewChapter(title: textField.text ?? "")
            }
            self.present(alert, animated: true)
        }
        let divider = makeMenu(children: [importFromFileAction, createAction])
        let reviewAction = UIAction(title: K.Texts.review, image: K.Image.book.safeUIImage) { _ in
            let viewModel = SelectChaptersViewModel(selectChapterFor: .review, delegate: self)
            let selectChapterVC = SelectChaptersViewController(viewModel: viewModel)
            let nav = UINavigationController(rootViewController: selectChapterVC)
            self.present(nav, animated: true)
        }
        let quizAction = UIAction(title: K.Texts.quiz, image: K.Image.book.safeUIImage) { _ in
            let viewModel = SelectChaptersViewModel(selectChapterFor: .quiz, delegate: self)
            let selectChapterVC = SelectChaptersViewController(viewModel: viewModel)
            let nav = UINavigationController(rootViewController: selectChapterVC)
            self.present(nav, animated: true)
        }
        let divider2 = makeMenu(children: [divider, reviewAction, quizAction])
        let settingsAction = UIAction(title: K.Texts.settings, image: K.Image.gear.safeUIImage) { _ in
            self.openSettings()
        }
        let refreshAction = UIAction(title: K.Texts.refresh, image: K.Image.refresh.safeUIImage) { _ in
            self.refresh()
        }
        let menu = makeMenu(children: [divider2, settingsAction, refreshAction])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: K.Image.ellipsis.safeUIImage, menu: menu)
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.largeTitleDisplayMode = .always

        filteredList = list
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = K.Texts.search
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
//        setupNotification()
//        let refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        tableView.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        Task {
            ProgressHUD.animationType = .horizontalDotScaling
            ProgressHUD.animate()
            await FirestoreManager.getData(isFromAppLaunch: false)
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    @objc func addTapped() {
        let docPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        docPickerController.delegate = self
        docPickerController.allowsMultipleSelection = true
        present(docPickerController, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let json = try? decoder.decode(ChapterStruct.self, from: json) {
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
            
            let newChapter = Chapter(chapterStruct: json)
            ChapterManager.shared.addChapter(chapter: newChapter)
            Task {
                await FirestoreManager.writeData(newChapter: newChapter)
            }
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
    
//    func setupNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: K.Notifications.selectedChapters, object: nil)
//    }
//    
//    @objc func notificationReceived() {
//        AppCache.shared.selectedChapters = AppCache.shared.reviewQuizSelectedChapters
////        let reviewVC = ReviewViewController()
////        self.navigationController?.pushViewController(reviewVC, animated: true)
//    }
    
    func openSettings() {
        let settingsVC = SettingsViewController()
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc func didTapToast() {
        AppCache.shared.isToastShown = false
        toast?.close()
        Task {
            ProgressHUD.animationType = .horizontalDotScaling
            ProgressHUD.animate()
            await FirestoreManager.getData(isFromAppLaunch: false)
            tableView.reloadData()
            ProgressHUD.dismiss()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func createNewChapter(title: String) {
        guard !title.isEmpty else {
            let alert = UIAlertController.showErrorAlert(message: "Title cannot be blank")
            self.present(alert, animated: true)
            return
        }
        
        guard !ChapterManager.shared.getChapters().contains(where: { $0.title == title }) else {
            let alert = UIAlertController.showErrorAlert(message: "\(title) is already used")
            self.present(alert, animated: true)
            return
        }
        
        let newChapter = Chapter(chapterStruct: ChapterStruct(title: title, wordList: [WordStruct]()))
        ChapterManager.shared.addChapter(chapter: newChapter)
        Task {
            await FirestoreManager.writeData(newChapter: newChapter)
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
        let chapter = isFiltering ? ChapterManager.shared.getChapter(title: filteredList[indexPath.row]) : ChapterManager.shared.getChapter(title: list[indexPath.row])
        content.text = chapter.title
        content.textProperties.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .regular)
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
        let wordsVM = WordsListViewModel(chapter: chapter, delegate: self)
        let wordsVC = WordsListViewController(viewModel: wordsVM)
        self.navigationController?.pushViewController(wordsVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isSearchBarEmpty
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let title = ChapterManager.shared.getChapter(at: indexPath.row).title
        let alert = UIAlertController.showDeleteConfirmationAlert(with: "Delete \(title)?", message: nil) {
            let removed = ChapterManager.shared.removeChapter(at: indexPath.row)
            Task {
                await FirestoreManager.deleteData(chapterIDToDelete: removed.id)
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        present(alert, animated: true)
    }
}

extension HomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            print(url)
            guard url.startAccessingSecurityScopedResource(), let data = try? Data(contentsOf: url) else {
                let alert = UIAlertController.showErrorAlert(title: "Error", message: "Unable to open file")
                self.present(alert, animated: true)
                return
            }
            parse(json: data)
        }
    }
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterListForSearch(searchText)
    }
}

extension HomeViewController: FirestoreDelegate {
    func didUpdate() {
        Log.debug("AppCache.shared.isToastShown: \(AppCache.shared.isToastShown)")
        guard !AppCache.shared.isToastShown else { return }
        Log.info("DIDUPDATE CALLED")

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapToast))
        let iconView = IconAppleToastView(image: K.Image.refresh.safeUIImage, title: "Update available", subtitle: "Tap to refresh", viewConfig: ToastViewConfiguration())
        let customToastView = AppleToastView(child: iconView)
        customToastView.addGestureRecognizer(tap)
        let config = ToastConfiguration(direction: .bottom, dismissBy: [.swipe(direction: .natural)])
        toast = Toast.custom(view: customToastView, config: config)
        toast?.show()
        AppCache.shared.isToastShown = true
    }
}

extension HomeViewController: WordsListDelegate {
    func didAddNewWord() {
        self.tableView.reloadData()
    }
}

extension HomeViewController: SelectChaptersDelegate {
    func didSelectChapter(_ chapters: [Chapter], destination: SelectChapterFor) {
        switch destination {
        case .review:
            let reviewVM = ReviewViewModel(chapters: chapters)
            let reviewVC = ReviewViewController(viewModel: reviewVM)
            self.navigationController?.pushViewController(reviewVC, animated: true)
        case .quiz:
            let quizVM = QuizViewModel(quizType: .blind, chapters: chapters)
            let quizVC = QuizViewController(viewModel: quizVM)
            self.navigationController?.pushViewController(quizVC, animated: true)
        }
    }
}
