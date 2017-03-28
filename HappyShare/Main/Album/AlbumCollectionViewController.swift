//
//  AlbumCollectionViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/15.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class AlbumCollectionViewController: UICollectionViewController {
    
    fileprivate let cellIdentifier = "AlbumCell"
    fileprivate let sectionHeaderIdentifier = "SectionHeader"
    fileprivate let defaultAlbumsTitle = ["文字","照片","录音","网页"]
    fileprivate var albums: [Album]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albums = HSCoreDataManager.sharedManager.allAlbums()
    }
    
    // MARK: - Target action
    @IBAction func synchronize(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func addNewAlbum(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "请添加您的合辑", preferredStyle: .alert)
        alertController.addTextField { (textField) in }
        let sureAction = UIAlertAction(title: "确定", style: .default) { [weak self] (alert) in
            if let name = alertController.textFields?.first?.text {
                if let album = HSCoreDataManager.sharedManager.addNewAlbum(name: name, picture: nil) {
                    self?.albums?.append(album)
                    self?.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (alert) in }
        alertController.addAction(sureAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = tiffanyBlue
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UICollectionViewCell, segue.identifier == "AlbumCVC -> NoteListTVC" {
            if let noteListTVC = segue.destination as? NoteListTableViewController {
                if let indexPath = collectionView?.indexPath(for: cell) {
                    if indexPath.section == 0 {
                        noteListTVC.type = .album
                        noteListTVC.album = albums?[indexPath.row]
                    } else if indexPath.section == 1 {
                        noteListTVC.type = .type
                        switch indexPath.row {
                        case 0: noteListTVC.noteType = .Words
                        case 1: noteListTVC.noteType = .Photo
                        case 2: noteListTVC.noteType = .Record
                        case 3: noteListTVC.noteType = .URL
                        default: break
                        }
                    }
                }
            }
        }
    }
}

extension AlbumCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (kScreenWidth - 8 * 4) / 3.0, height: (kScreenWidth - 8 * 4) / 3.0 + 34.0)
    }
}

// MARK: - UICollectionViewDataSource
extension AlbumCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return albums?.count ?? 0
        case 1: return 4
        default: return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as? UIImageView
        let titleLabel = cell.contentView.viewWithTag(2) as? UILabel
        if indexPath.section == 0 {
            if let picture = albums?[indexPath.row].picture {
                imageView?.image = UIImage(data: picture as Data)
            }
            titleLabel?.text = albums?[indexPath.row].name
        }
        if indexPath.section == 1 {
            titleLabel?.text = defaultAlbumsTitle[indexPath.row]
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderIdentifier, for: indexPath)
            return headerView
        }
        return UICollectionReusableView()
    }
    
}
