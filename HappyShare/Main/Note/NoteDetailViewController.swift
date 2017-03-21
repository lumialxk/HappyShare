//
//  NoteDetailViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/25.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {

    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var tagCollectionView: UICollectionView!

    var note: Note?
    var deletedTags = [Tag]()
    
    fileprivate let tagCellIdentifier = "TagCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NoteDetailViewController.didReceiveNoteModifyNotification), name: NSNotification.Name(rawValue: kNoteDidModifyNotification), object: nil)
        configureSubviews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func configureSubviews() {
        albumButton.setTitle(note?.album?.name, for: .normal)
        tagCollectionView.reloadData()
    }
    
    @IBAction func chooseAlbum(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        if let albums = HSCoreDataManager.sharedManager.allAlbums() {
            for album in albums {
                let action = UIAlertAction(title: album.name, style: .default, handler: { (action) -> Void in
                    HSCoreDataManager.sharedManager.moveNote(note: self.note, toAlbum: album)
                    sender.setTitle(album.name, for: .normal)
                })
                actionSheet.addAction(action)
            }
        }
        let action = UIAlertAction(title: "取消", style: .cancel, handler: { (action) -> Void in
        })
        actionSheet.addAction(action)
        actionSheet.view.tintColor = tiffanyBlue
        present(actionSheet, animated: true, completion: nil)
    }

    func didReceiveNoteModifyNotification(notif: NSNotification) {
        if let noteUUID = notif.object as? String {
            if note?.uuid == noteUUID {
                configureSubviews()
            }
        }
    }

}

// MARK: - UICollectionViewDataSource
extension NoteDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (note?.tags?.count ?? 0) + deletedTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellIdentifier, for: indexPath)
        let tagLabel = cell.viewWithTag(1) as? UILabel
        if let tag = indexPath.row < (note?.tags?.count ?? 0) ? note?.tags?[indexPath.row] as? Tag : (deletedTags as NSArray)[indexPath.row - (note?.tags?.count ?? 0)] as? Tag {
            tagLabel?.text = tag.name
            if deletedTags.contains(tag) {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NoteDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let tags = Array(note!.tags!) as! [Tag]
        guard let name = indexPath.row < (tags.count ?? 0) ? tags[indexPath.row].name : ((deletedTags as NSArray)[indexPath.row - tags.count] as? Tag)?.name else {
            return CGSize.zero
        }
        // 依据文字计算宽度
        let rect = (name as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
        return CGSize(width: ceil(rect.width), height: 20)
    }
}

// MARK: - UICollectionViewDelegate
extension NoteDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = indexPath.row < (note?.tags?.count ?? 0) ? note?.tags?[indexPath.row] as? Tag : (deletedTags as NSArray)[indexPath.row - (note?.tags?.count ?? 0)] as? Tag else {
            return
        }
        if let index = deletedTags.index(of: tag), deletedTags.contains(tag) {
            HSCoreDataManager.sharedManager.addTag(tag: tag, toNote: note)
            deletedTags.remove(at: index)
        } else {
            HSCoreDataManager.sharedManager.deleteTag(tag: tag, inNote: &note)
            deletedTags.append(tag)
        }
        collectionView.reloadData()
    }
}
