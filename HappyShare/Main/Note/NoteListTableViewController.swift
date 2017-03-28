//
//  NoteListTableViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/18.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit
//import GoogleMobileAds

// MARK: - NoteListType
enum NoteListType {
    case tag
    case album
    case type
}

class NoteListTableViewController: UITableViewController {
    
    var type = NoteListType.tag
    var tag: Tag?
    var album: Album?
    var noteType: NoteType?
    fileprivate var notes: [Note]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NoteListTableViewController.didReceiveNoteModifyNotification), name: Notification.Name(rawValue: kNoteDidModifyNotification), object: nil)
        navigationItem.rightBarButtonItem = editButtonItem
        editButtonItem.title = "编辑"
//        createAd()
        configureSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureSubviews() {
        switch type {
        case .tag: notes = HSCoreDataManager.sharedManager.notesWithTag(tag: tag)
        case .album: notes = HSCoreDataManager.sharedManager.notesInAlbum(album: album)
        case .type: notes = HSCoreDataManager.sharedManager.notesWithType(type: noteType)
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? NoteTableViewCell, segue.identifier == "NoteVC -> CellDetailVC" {
            if let noteDetailVC = segue.destination as? NoteDetailViewController {
                if let indexPath = tableView.indexPath(for: cell) {
                    noteDetailVC.note = notes?[indexPath.row]
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        notes = HSCoreDataManager.sharedManager.allNotes()
        tableView.reloadData()
        sender.endRefreshing()
    }
    
    func didReceiveNoteModifyNotification(notif: NSNotification) {
        if let noteUUID = notif.object as? String,let notes = notes {
            for index in 0..<notes.count {
                if notes[index].uuid == noteUUID {
                    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        editButtonItem.title = editing ? "完成" : "编辑"
    }

}

// MARK: - UITableViewDataSource
extension NoteListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCellIdentifier(type: NoteType(rawValue: notes?[indexPath.row].type ?? "None")).rawValue, for: indexPath) as! NoteTableViewCell
        cell.note = notes?[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NoteListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell, cell.note?.type == .none {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NoteCellHeight(type: NoteType(rawValue: notes?[indexPath.row].type ?? "None")).rawValue
    }
    
    // Edit Actions
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        let deleteAction = UITableViewRowAction(style: .default, title: "删除") { (action, indexPath) -> Void in
            if let note = self.notes?[indexPath.row] {
                HSCoreDataManager.sharedManager.deleteNote(note: note)
                self.notes?.remove(at: indexPath.row)
                if self.notes?.count == 0 {
                    tableView.deleteSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        deleteAction.backgroundColor = UIColor.red
        let raiseToTopAction = UITableViewRowAction(style: .normal, title: "置顶") { (action, indexPath) -> Void in
            if let note = self.notes?[indexPath.row] {
                HSCoreDataManager.sharedManager.moveNote(note: note, toOrder: 0)
                if let note = self.notes?.remove(at: indexPath.row) {
                    self.notes?.insert(note, at: 0)
                }
                var indexPaths = [IndexPath]()
                for index in 0...indexPath.row {
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
                tableView.reloadRows(at: indexPaths, with: .none)
            }
        }
        raiseToTopAction.backgroundColor = UIColor(colorLiteralRed: 172.0/255.0, green: 172.0/255.0, blue: 172.0/255.0, alpha: 1.0)
        actions.append(deleteAction)
        actions.append(raiseToTopAction)
        return actions
    }
    
    // Rearrange
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let note = notes?[sourceIndexPath.row] {
            HSCoreDataManager.sharedManager.moveNote(note: note, toOrder: destinationIndexPath.row)
        }
    }

}

//extension NoteListTableViewController: GADBannerViewDelegate {
//    
//    private func createAd() {
//        let adView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
//        adView.adUnitID = adMobId
//        adView.rootViewController = self
//        let request = GADRequest()
//        request.testDevices = ["17ac37802dba669c9504cfae833db0d6"]
//        adView.loadRequest(GADRequest())
//        adView.delegate = self
//        tableView.tableHeaderView = adView
//    }
//    
//    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
//        tableView.tableHeaderView = nil
//    }
//    
//}

