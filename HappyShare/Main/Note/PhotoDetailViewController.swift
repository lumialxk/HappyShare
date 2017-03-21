//
//  PhotoDetailViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/19.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class PhotoDetailViewController: NoteDetailViewController {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var remarkLabel: UILabel!
    
    fileprivate let photoCellIdentifier = "PhotoCell"
    fileprivate var selectedIndexPath: IndexPath?
    var photos: [Data]?
    var photoImages: [UIImage]?
    fileprivate lazy var menuController: UIMenuController = {
        let menuController = UIMenuController.shared
        let shareItem = UIMenuItem(title: "分享", action: #selector(PhotoDetailViewController.sharePhoto))
        let copyItem = UIMenuItem(title: "复制", action: #selector(PhotoDetailViewController.copyPhoto))
        menuController.menuItems = [shareItem, copyItem]
        return menuController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = note?.data {
            photos = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [Data]
        }
        photoImages = photos?.map({ (photo) -> UIImage in
            UIImage(data: photo)!
        })
        if let layout = photoCollectionView.collectionViewLayout as? LXKCollectionViewWaterfallFlowLayout {
            layout.cellHeightAtIndex = {[unowned self](indexPath: IndexPath,width) -> CGFloat in
                return self.photoImages![indexPath.row].size.compatibleHeight(withWidth: width)
            }
        }
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        remarkLabel.text = note?.title
        photoCollectionView.reloadData()
    }
    
    // Target action

    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let photos = photos else {
            return
        }
        let activityVC = UIActivityViewController(activityItems: photos, applicationActivities: nil)
        activityVC.view.tintColor = tiffanyBlue
        navigationController?.present(activityVC, animated: true, completion: nil)
    }
    
    func sharePhoto() {
        if let row = selectedIndexPath?.row {
            let activityVC = UIActivityViewController(activityItems: [photos![row]], applicationActivities: nil)
            activityVC.view.tintColor = tiffanyBlue
            navigationController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func copyPhoto() {
        let pasteboard = UIPasteboard.general
        if let row = selectedIndexPath?.row {
            pasteboard.image = UIImage(data: photos![row])
        }
    }

    
}

extension PhotoDetailViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
            return photos?.count ?? 0
        }
        if collectionView == tagCollectionView {
            return super.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        if collectionView == photoCollectionView {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
            if let photoImageView = cell?.viewWithTag(1) as? UIImageView {
                photoImageView.image = photoImages![indexPath.row]
            }
        }
        if collectionView == tagCollectionView {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        guard let collectionViewCell = cell else {
            return UICollectionViewCell()
        }
        return collectionViewCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoDetailViewController {

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == tagCollectionView {
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        }
        return CGSize.zero
    }
}

extension PhotoDetailViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView {
            if selectedIndexPath == indexPath {
                menuController.setMenuVisible(false, animated: true)
                selectedIndexPath = nil
                return
            }
            if let cell = collectionView.cellForItem(at: indexPath) {
                selectedIndexPath = indexPath
                cell.becomeFirstResponder()
                menuController.setTargetRect(cell.frame, in: cell.superview!)
                menuController.setMenuVisible(true, animated: true)
            }
        }
        if collectionView == tagCollectionView {
            super.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
}









