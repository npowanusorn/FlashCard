//
//  WordListViewController.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit

class WordListViewController: UIViewController {
    
    let chapter: String
    let defaults = UserDefaults.standard
    var wordsDictArr: [String:String] = [:]
    @IBOutlet weak var tableView: UITableView!
    
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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "wordsCell")
        let dicts = defaults.object(forKey: chapter) as? [String: String] ?? [:]
        wordsDictArr = dicts
    }
}
    // MARK: - Table view data source

extension WordListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsDictArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
