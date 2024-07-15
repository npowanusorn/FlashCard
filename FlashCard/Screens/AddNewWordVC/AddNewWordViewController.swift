//
//  AddNewWordViewController.swift
//  FlashCard
//
//  Created by Nucha Powanusorn on 15/07/2024.
//

import UIKit

class AddNewWordViewController: UIViewController {

    let viewModel: AddNewWordViewModel
    
    @IBOutlet weak var wordTextField: BaseTextField!
    @IBOutlet weak var meaningTextField: BaseTextField!
    @IBOutlet weak var addButton: BounceButton!
    
    private var word: String {
        wordTextField.text ?? ""
    }
    private var meaning: String {
        meaningTextField.text ?? ""
    }
    
    init(viewModel: AddNewWordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        wordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        meaningTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addButton.isEnabled = false
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("\(word), \(meaning)")
        let newWord = WordList(wordStruct: WordStruct(korDef: word, enDef: meaning, syn: "", ant: "", korExSe: "", enExSe: "", descr: ""))
        viewModel.chapter.addWord(new: newWord)
        Task {
            await FirestoreManager.writeData(newWord: newWord, for: viewModel.chapter)
        }
        viewModel.delegate.didAddNewWord()
        self.dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ sender: BaseTextField) {
        addButton.isEnabled = !word.isEmpty && !meaning.isEmpty
    }
    
    @objc private func dismissView() {
        if !word.isEmpty || !meaning.isEmpty {
            let alert = UIAlertController.showUnsavedChangesSheet {
                self.dismiss(animated: true)
            }
            self.present(alert, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
}
