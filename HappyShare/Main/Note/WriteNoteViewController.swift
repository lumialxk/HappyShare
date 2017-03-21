//
//  WriteNoteViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/25.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class WriteNoteViewController: UIViewController {

    @IBOutlet weak var albumButton: UIButton!
    
    var note: Note?
    var tags: [Tag]?
    var selectedTags = [Tag]()
    var selectedAlbum: Album?
    fileprivate let tagCellIdentifier = "TagCell"

    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let noteTags = note?.tags {
            for noteTag in noteTags {
                if let tag = noteTag as? Tag {
                    selectedTags.append(tag)
                }
            }
        }
        selectedAlbum = note?.album
        tags = HSCoreDataManager.sharedManager.allTags(byHot: true)
        albumButton.setTitle(selectedAlbum?.name ?? "待阅箱", for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 选择合辑
    @IBAction func chooseAlbum(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        if let albums = HSCoreDataManager.sharedManager.allAlbums() {
            for album in albums {
                let action = UIAlertAction(title: album.name, style: .default, handler: { (action) -> Void in
                    self.selectedAlbum = album
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

}

// MARK: - UICollectionViewDataSource
extension WriteNoteViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellIdentifier, for: indexPath)
        let tagLabel = cell.viewWithTag(1) as? UILabel
        tagLabel?.text = tags?[indexPath.row].name
        if let tag = tags?[indexPath.row] {
            if selectedTags.contains(tag) {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WriteNoteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 依据文字计算宽度
        guard let name = tags?[indexPath.row].name else {
            return CGSize.zero
        }
        let rect = (name as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
        return CGSize(width: ceil(rect.width), height: 44)
    }
}

// MARK: - UICollectionViewDelegate
extension WriteNoteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = tags?[indexPath.row] else {
            return
        }
        if let index = selectedTags.index(of: tag), selectedTags.contains(tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UITextFieldDelegate
extension WriteNoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

