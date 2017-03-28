//
//  WritePhotoNoteViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/19.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

private let cellWidth = (kScreenWidth - 5 * 10) / 3.0
private let shakeAnimationKey = "shake"

class WritePhotoNoteViewController: WriteNoteViewController {
    var photos: [Data]?
    var photoImages: [UIImage]?
    fileprivate let photoCellIdentifier = "PhotoCell"
    fileprivate var selectedIndexPath: IndexPath?
    fileprivate lazy var menuController: UIMenuController = {
        let menuController = UIMenuController.shared
        let editItem = UIMenuItem(title: "编辑", action: #selector(WritePhotoNoteViewController.editPhoto))
        let copyItem = UIMenuItem(title: "复制", action: #selector(WritePhotoNoteViewController.copyPhoto))
        let deleteItem = UIMenuItem(title: "删除", action: #selector(WritePhotoNoteViewController.deletePhoto))
        menuController.menuItems = [editItem, copyItem, deleteItem]
        return menuController
    }()
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tags = HSCoreDataManager.sharedManager.allTags(byHot: true)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(WritePhotoNoteViewController.longPressPhotoCollectionView))
        longPress.minimumPressDuration = 0.25
        photoCollectionView.addGestureRecognizer(longPress)
        photoImages = photos?.map({ (photo) -> UIImage in
            UIImage(data: photo)!
        })
        if let layout = photoCollectionView.collectionViewLayout as? LXKCollectionViewWaterfallFlowLayout {
            layout.cellHeightAtIndex = {[unowned self](indexPath: IndexPath,width) -> CGFloat in
                return self.photoImages![indexPath.row].size.compatibleHeight(withWidth: width)
            }
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if isEditing {
            isEditing = false
            // 将可见cell的动画关闭
            for cell in photoCollectionView.visibleCells {
                let photoImageView = cell.viewWithTag(1) as? UIImageView
                photoImageView?.pauseShakeAnimation()
            }
            sender.title = "保存"
        } else {
            let data = NSKeyedArchiver.archivedData(withRootObject: photos ?? [])
            HSCoreDataManager.sharedManager.addNewNote(title: titleTextField.text, icon: photos?.first as NSData?, content: nil, url: nil, type: NoteType.Photo.rawValue, data: data as NSData?, album: nil, tags: selectedTags)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func longPressPhotoCollectionView(sender: UILongPressGestureRecognizer) {
        guard isEditing else {
            return
        }
        let point = sender.location(in: photoCollectionView)
        // 将手势传递给CollectionView
        switch sender.state {
        case .began:
            guard let indexPath = photoCollectionView.indexPathForItem(at: point) else {
                return
            }
            photoCollectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            photoCollectionView.updateInteractiveMovementTargetPosition(point)
        case .ended:
            photoCollectionView.endInteractiveMovement()
        default:
            photoCollectionView.cancelInteractiveMovement()
        }
    }
    
    func editPhoto() {
        isEditing = true
        // 将可见cell的动画开启
        for cell in photoCollectionView.visibleCells {
            let photoImageView = cell.viewWithTag(1) as? UIImageView
            photoImageView?.resumeShakeAnimation()
        }
        saveBarButtonItem.title = "完成"
    }
    
    func copyPhoto() {
        // 将图片复制到剪切板
        let pasteboard = UIPasteboard.general
        if let row = selectedIndexPath?.row {
            pasteboard.image = UIImage(data: photos![row])
        }
    }
    
    func deletePhoto() {
        if let selectedIndexPath = selectedIndexPath {
            photos?.remove(at: selectedIndexPath.row)
            photoImages?.remove(at: selectedIndexPath.row)
            photoCollectionView.deleteItems(at: [selectedIndexPath])
        }
    }
}

// MARK: - UICollectionViewDataSource
extension WritePhotoNoteViewController {
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
                if isEditing {
                    photoImageView.resumeShakeAnimation()
                } else {
                    photoImageView.pauseShakeAnimation()
                }
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
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView == photoCollectionView {
            return true
        }
        return false
    }

    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        collectionView.layoutIfNeeded()
        if let photo = photos?.remove(at: sourceIndexPath.row),let photoImage = photoImages?.remove(at: sourceIndexPath.row) {
            photos?.insert(photo, at: destinationIndexPath.row)
            photoImages?.insert(photoImage, at: destinationIndexPath.row)
            collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WritePhotoNoteViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagCollectionView {
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        return CGSize.zero
    }
}

// MARK: - UICollectionViewDelegate
extension WritePhotoNoteViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView && !isEditing {
            if selectedIndexPath == indexPath {
                // 隐藏菜单栏
                menuController.setMenuVisible(false, animated: true)
                selectedIndexPath = nil
                return
            }
            if let cell = collectionView.cellForItem(at: indexPath) {
                selectedIndexPath = indexPath
                // 显示菜单栏
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

extension UICollectionViewCell {
    open override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
}

private extension UIImageView {
    
    // 暂停动画
    func pauseShakeAnimation() {
        self.layer.speed = 0.0
    }
    
    // 恢复/开始动画
    func resumeShakeAnimation() {
        if self.layer.animation(forKey: shakeAnimationKey) == nil {
            addShakeAnimation()
        }
        self.layer.speed = 1.0
    }
    
    // 添加动画
    func addShakeAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.1
        animation.fromValue = NSNumber(value: -M_1_PI / 4.0)
        animation.toValue = NSNumber(value: M_1_PI / 4.0)
        animation.repeatCount = HUGE
        animation.autoreverses = true
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer.add(animation, forKey: shakeAnimationKey)
    }
}










