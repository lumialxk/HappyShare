//
//  TagViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/14.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

public let kTagOrderByHotKey = "kTagOrderByHotKey"

class TagViewController: UIViewController {
    
    @IBOutlet weak var orderBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    fileprivate let cellIdentifier = "TagCell"
    fileprivate var tagsInPinyin = [String:[Tag]]()
    fileprivate var tags: [Tag]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureSubviews() {
        let orderredByHot = UserDefaults.standard.bool(forKey: kTagOrderByHotKey)
        tags = HSCoreDataManager.sharedManager.allTags(byHot: orderredByHot)
        if let tagsInPinyin = sortTagsIntoGroups(tags: tags) {
            self.tagsInPinyin = tagsInPinyin
            tableView.reloadData()
        }
        orderBarButtonItem.title = orderredByHot ? "热度" : "名称"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, segue.identifier == "TagVC -> NoteListTVC" {
            if let noteListTVC = segue.destination as? NoteListTableViewController {
                if let indexPath = tableView.indexPath(for: cell) {
                    noteListTVC.type = .tag
                    let keysInOrder = tagsInPinyin.keys.sorted()
                    noteListTVC.tag = tagsInPinyin[keysInOrder[indexPath.section]]?[indexPath.row]
                }
            }
        }
    }

    // MARK: - Target action
    @IBAction func addNewTag(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "请添加您的标签", preferredStyle: .alert)
        alertController.addTextField { (textField) in }
        let sureAction = UIAlertAction(title: "确定", style: .default) { [weak self] (alert) in
            if let name = alertController.textFields?.first?.text?.trimmingCharacters(in: NSCharacterSet.whitespaces), name.lengthOfBytes(using: String.Encoding.utf8) != 0 {
                if let tag = HSCoreDataManager.sharedManager.addNewTag(name: name) {
                    self?.tags?.append(tag)
                    if let tagsInPinyin = self?.sortTagsIntoGroups(tags: self?.tags) {
                        self?.tagsInPinyin = tagsInPinyin
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (alert) in }
        alertController.addAction(sureAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = tiffanyBlue
        present(alertController, animated: true) { () -> Void in
            
        }
    }

    // 按 热度/名称 排序
    @IBAction func orderTags(_ sender: UIBarButtonItem) {
        let orderredByHot = UserDefaults.standard.bool(forKey: kTagOrderByHotKey)
        UserDefaults.standard.set(!orderredByHot, forKey: kTagOrderByHotKey)
        configureSubviews()
    }
    
    // MARK: - Help methods
    
    // tags按首字母不同分组
    private func sortTagsIntoGroups(tags: [Tag]?) -> [String:[Tag]]? {
        guard let tags = tags else {
            return nil
        }
        let pinyins = tags.map { (tag) -> String in
            return tag.name?.pinyin ?? "#"
        }
        var pinyinGroups = [String:[Tag]]()
        for index in 0..<pinyins.count {
            let firstPinyin = String(pinyins[index].characters.first ?? "#")
            if pinyinGroups.keys.contains(firstPinyin) {
                if let newElements = pinyinGroups[firstPinyin]?.append(tags[index]) as? AnyObject as? [Tag] {
                    pinyinGroups.updateValue(newElements, forKey: firstPinyin)
                }
            } else {
                pinyinGroups.updateValue([tags[index]], forKey: firstPinyin)
            }
        }
        return pinyinGroups
    }

}

// MARK: - UITableViewDataSource
extension TagViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tagsInPinyin.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keysInOrder = tagsInPinyin.keys.sorted()
        return tagsInPinyin[keysInOrder[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let iconLabel = cell.contentView.viewWithTag(1) as? UILabel
        let titleLabel = cell.contentView.viewWithTag(2) as? UILabel
        let keysInOrder = tagsInPinyin.keys.sorted()
        if let iconTitle = tagsInPinyin[keysInOrder[indexPath.section]]?[indexPath.row].name?.pinyin.characters.first {
            iconLabel?.text = String(iconTitle)
        }
        titleLabel?.text = tagsInPinyin[keysInOrder[indexPath.section]]?[indexPath.row].name
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keysInOrder = tagsInPinyin.keys.sorted()
        let firstCharacter = keysInOrder[section].characters.first ?? "#"
        return String(firstCharacter).uppercased()
    }
    
    private func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }

    private func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let keysInOrder = tagsInPinyin.keys.sorted()
            if tableView.numberOfRows(inSection: indexPath.section) == 1 {
                if let tags = tagsInPinyin.removeValue(forKey: keysInOrder[indexPath.section]) {
                    if let tag = tags.first {
                        HSCoreDataManager.sharedManager.deleteTag(tag: tag)
                        if let index = self.tags?.index(of: tag) {
                            self.tags?.remove(at: index)
                        }
                    }
                }
                tableView.deleteSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .fade)
            } else {
                if let tag = tagsInPinyin[keysInOrder[indexPath.section]]?.remove(at: indexPath.row) {
                    HSCoreDataManager.sharedManager.deleteTag(tag: tag)
                    if let index = tags?.index(of: tag) {
                        tags?.remove(at: index)
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

}




public extension String {
    var pinyin: String {
        let cfString = CFStringCreateMutableCopy(nil, 0, self as CFString!)
        CFStringTransform(cfString, nil, kCFStringTransformMandarinLatin, false)      // 带声调拼音
        CFStringTransform(cfString, nil, kCFStringTransformStripDiacritics, false)    // 去声调拼音
        return String(describing: cfString)
    }
}





