//
//  WordsViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import SwiftUI

class WordsListViewController: UIViewController {

    private let viewModel: WordsListViewModel
    private var chapter: Chapter { viewModel.chapter }
    private var wordList: [WordList] { chapter.wordList }
    private let defaults = UserDefaults.standard
    
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var emptyTableLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var segmentedControl: SCView!
    @IBOutlet private weak var tableView: UITableView!
    
    init(viewModel: WordsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = chapter.title
        self.navigationItem.largeTitleDisplayMode = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.CellIDs.wordsVCID)
        self.tableView.allowsSelectionDuringEditing = true
        setupSegmentedControl()
        self.navigationItem.rightBarButtonItem?.isEnabled = !wordList.isEmpty
        makeMenu()
        emptyTableLabel.text = "No word in this chapter"
        addButton.setTitle("Add new word", for: .normal)
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        showHideElementsAsAppropriate()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addNewWord()
    }
    
    func didTapSegment(_ segment: Int) {
        tableView.reloadData()
    }
    
    private func showHideElementsAsAppropriate() {
        tableView.isHidden = wordList.isEmpty
        stackView.isHidden = !wordList.isEmpty
    }
    
    @objc func segmentedControlChanged() {
        tableView.reloadData()
    }
    
    func setupSegmentedControl() {
        segmentedControl.didTapSegment = didTapSegment(_:)
        segmentedControl.backgroundColor = .tertiarySystemGroupedBackground
        segmentedControl.currentIndexBackgroundColor = .systemFill
        segmentedControl.borderColor = .clear
        segmentedControl.borderWidth = 0
        segmentedControl.numberOfSegments = 3
        segmentedControl.segmentsTitle = [K.Texts.all, K.Texts.kor, K.Texts.en]
        segmentedControl.isHidden = true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        if editing {
            self.navigationItem.leftBarButtonItem = editButtonItem
            self.navigationItem.rightBarButtonItem?.isHidden = true
        } else {
            makeMenu()
        }
    }
    
    func makeMenu() {
        let reviewAction = UIAction(title: K.Texts.review, image: K.Image.book.safeUIImage) { _ in
            let reviewVC = ReviewViewController()
            self.navigationController?.pushViewController(reviewVC, animated: true)
        }
        let quizAction = UIAction(title: K.Texts.quiz, image: K.Image.book.safeUIImage) { _ in
            // TODO
        }
        let submenu = UIMenu(options: .displayInline, children: [reviewAction, quizAction])
        let addAction = UIAction(title: "Add", image: K.Image.plus.safeUIImage) { _ in
            self.addNewWord()
        }
        let editAction = UIAction(title: "Edit", image: K.Image.pencil.safeUIImage) { _ in
            Log.info("EDIT")
            self.setEditing(true, animated: true)
        }
        let menu = UIMenu(options: .displayInline, children: [submenu, addAction, editAction])
        self.navigationItem.rightBarButtonItem = isEditing ? editButtonItem : UIBarButtonItem(image: K.Image.ellipsis.safeUIImage, menu: menu)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.backButtonDisplayMode = .default
    }
    
    func addNewWord() {
        let addNewWordViewModel = AddNewWordViewModel(chapter: chapter, delegate: self)
        let addNewWordVC = AddNewWordViewController(viewModel: addNewWordViewModel)
        let navVC = UINavigationController(rootViewController: addNewWordVC)
        present(navVC, animated: true)
    }
}

// MARK: - Table view data source
extension WordsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Number of words: \(wordList.count)"
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.wordsVCID, for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.secondaryTextProperties.numberOfLines = 0
        content.textProperties.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .regular)
        content.prefersSideBySideTextAndSecondaryText = true
        content.text = wordList[indexPath.row].korDef
        content.secondaryText = wordList[indexPath.row].enDef
        if segmentedControl.currentIndex == 1 {
            content.secondaryTextProperties.color = UIColor.label.withAlphaComponent(0)
        } else if segmentedControl.currentIndex == 2 {
            content.textProperties.color = UIColor.label.withAlphaComponent(0)
        }
        cell.contentConfiguration = content
        cell.selectionStyle = tableView.isEditing ? .default : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        Log.info(indexPath.row)
    }
}

extension WordsListViewController: AddNewWordDelegate {
    func didAddNewWord() {
        viewModel.delegate.didAddNewWord()
        self.tableView.reloadData()
        self.showHideElementsAsAppropriate()
    }
}
