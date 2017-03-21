//
//  NoteViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/14.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit
//import GoogleMobileAds
import SafariServices

// MARK: - Enum NoteCellIdentifier
enum NoteCellIdentifier: String {
    init(type: NoteType?) {
        guard let type = type else {
            self = .None
            return
        }
        switch type {
        case .Photo: self = NoteCellIdentifier.Photo
        case .URL: self = NoteCellIdentifier.URL
        case .Record: self = NoteCellIdentifier.Record
        case .Words: self = NoteCellIdentifier.Words
        case .None: self = NoteCellIdentifier.None
        }
    }
    case Photo = "PhotoNoteCell"
    case URL = "URLNoteCell"
    case Record = "RecordNoteCell"
    case Words = "WordsNoteCell"
    case None = "ErrorCell"
}

// MARK: - Enum NoteCellHeight
enum NoteCellHeight: CGFloat {
    init(type: NoteType?) {
        guard let type = type else {
            self = .None
            return
        }
        switch type {
        case .Photo: self = NoteCellHeight.Photo
        case .URL: self = NoteCellHeight.URL
        case .Record: self = NoteCellHeight.Record
        case .Words: self = NoteCellHeight.Words
        case .None: self = NoteCellHeight.None
        }
    }
    case Photo = 80.0
    case URL = 120.0
    case Record = 44.0
    case Words = 100.0
    case None = 30.0
}


class NoteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var notes: [Note]?
    fileprivate var photos: [Data]?
    private var passed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NoteViewController.didReceiveNoteModifyNotification), name: Notification.Name(rawValue: kNoteDidModifyNotification), object: nil)
        navigationItem.rightBarButtonItem = editButtonItem
        editButtonItem.title = "编辑"
        notes = HSCoreDataManager.sharedManager.allNotes()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NoteViewController.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
//        createAd()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: kEnablePassword) && !passed {
            performSegue(withIdentifier: "NoteVC -> EnterPasswordVC", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? NoteTableViewCell, segue.identifier == "NoteVC -> CellDetailVC" {
            if let noteDetailVC = segue.destination as? NoteDetailViewController {
                if let indexPath = tableView.indexPath(for: cell) {
                    noteDetailVC.note = notes?[indexPath.row]
                }
            }
        }
        if let multiPhotoPickerNavigationController = segue.destination as? UINavigationController, segue.identifier == "NoteVC -> MultiPhotoPickerVC" {
            if let multiPhotoPickerVC = multiPhotoPickerNavigationController.viewControllers.first as? LXKAssetGridViewController {
                multiPhotoPickerVC.delegate = self
            }
        }
        if let writePhotoNoteVC = segue.destination as? WritePhotoNoteViewController, segue.identifier == "NoteVC -> WritePhotoNoteVC" {
            writePhotoNoteVC.photos = photos
        }
        if let enterPasswordVC = segue.destination as? EnterPasswordViewController, segue.identifier == "NoteVC -> EnterPasswordVC" {
            enterPasswordVC.type = .Verify
            enterPasswordVC.passwordDidPass = {(password, success) in
                self.passed = success
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "NoteVC -> MultiPhotoPickerVC" {
            switch PHPhotoLibrary.authorizationStatus() {
            case .denied:
                showAuthorizeAlertView(notice: "乐享 没有使用相册的权限,\n如果设置权限,请点击设置\n并启用相册",sender: self)
                return false
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    if status == .authorized {
                        self.performSegue(withIdentifier: "NoteVC -> MultiPhotoPickerVC", sender: self)
                    }
                })
                return false
            case .restricted: return false
            case .authorized: break
            }
        }
        return true
    }

    // Target action
    
    @IBAction func OpenSafari(_ sender: UIButton) {
        let safariVC = SFSafariViewController(url: URL(string: "https://www.baidu.com")!, entersReaderIfAvailable: true)
        safariVC.view.tintColor = tiffanyBlue
        present(safariVC, animated: true, completion: nil)
    }
    
    func refresh(sender: UIRefreshControl) {
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
extension NoteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCellIdentifier(type: NoteType(rawValue: notes?[indexPath.row].type ?? "None")).rawValue, for: indexPath) as! NoteTableViewCell
        cell.note = notes?[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NoteCellHeight(type: NoteType(rawValue: notes?[indexPath.row].type ?? "None")).rawValue
    }
    
    
    
    // Edit Actions
    private func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
    private func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if let note = notes?[fromIndexPath.row] {
            HSCoreDataManager.sharedManager.moveNote(note: note, toOrder: toIndexPath.row)
        }
    }

}

extension NoteViewController: LXKPhotoPickerDelegate {
    func didChoosePhotos(photos: NSMutableArray!) {
        if let photos = photos as AnyObject as? [Data] {
            self.photos = photos
        }
        performSegue(withIdentifier: "NoteVC -> WritePhotoNoteVC", sender: nil)
    }
}

//extension NoteViewController: GADBannerViewDelegate {
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

// MARK: - Custom table view cell
class NoteTableViewCell: UITableViewCell {
    var note: Note?
}

class WordsNoteTableViewCell: NoteTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    override var note: Note? {
        didSet {
            titleLabel.text = note?.title
            contentLabel.text = note?.content
        }
    }
}

class URLNoteTableViewCell: NoteTableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    override var note: Note? {
        didSet {
            if let icon = note?.icon {
                iconImageView.image = UIImage(data: icon as Data)
            } else {
                iconImageView.image = UIImage(named: placeholderImageName)
            }
            titleLabel.text = note?.title
            contentLabel.text = note?.content
        }
    }
}

class RecordNoteTableViewCell: NoteTableViewCell {
    
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override var note: Note? {
        didSet {
            
            titleLabel.text = note?.title
        }
    }
}

class PhotoOrVideoTableViewCell: NoteTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override var note: Note? {
        didSet {
            titleLabel.text = note?.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateLabel.text = dateFormatter.string(from: note?.createDate as Date? ?? Date())
            contentLabel.text = note?.content
            if let data = note?.icon {
                photoImageView.image = UIImage(data: data as Data)
            } else {
                photoImageView.image = UIImage(named: placeholderImageName)
            }
        }
    }
}










