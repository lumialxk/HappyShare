//
//  ShareViewController.swift
//  乐享
//
//  Created by 李现科 on 16/1/14.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    private let limitedCharacterCount = 200
    private let tiffanyBlue = UIColor(red: 129.0/255.0, green: 216.0/255.0, blue: 207.0/255.0, alpha: 1.0)

    private var selectedAlbum: Album?
    private var selectedTags: [Tag]?
    
    private var images = [Data]()
    private var audioData: Data?
    private var url: URL?
    private var string: String?
    private var filePath: URL?
    private var fileData: Data?
    private var htmlData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.navigationBar.tintColor = tiffanyBlue
        fetchItemData()
    }
    
    
    
    override func isContentValid() -> Bool {
        let contentLength = contentText.lengthOfBytes(using: String.Encoding.utf8)
        charactersRemaining = NSNumber(value: limitedCharacterCount - contentLength)
        if charactersRemaining.intValue < 0 {
            return false
        }
        return true
    }

    override func didSelectPost() {
        if let audioData = audioData {
            HSCoreDataManager.sharedManager.addNewNote(title: contentText, icon: nil, content: string, url: nil, type: NoteType.Record.rawValue, data: audioData as NSData?, album: selectedAlbum, tags: selectedTags)
        } else if let url = url {
            HSCoreDataManager.sharedManager.addNewNote(title: contentText, icon: images.first as NSData?, content: string, url: url.absoluteString, type: NoteType.URL.rawValue, data: nil, album: selectedAlbum, tags: selectedTags)
        } else if let htmlData = htmlData {
            HSCoreDataManager.sharedManager.addNewNote(title: contentText, icon: images.first as NSData?, content: string, url: nil, type: NoteType.URL.rawValue, data: htmlData as NSData?, album: selectedAlbum, tags: selectedTags)
        } else if images.count > 0 {
            HSCoreDataManager.sharedManager.addNewNote(title: string ?? contentText, icon: images.first as NSData?, content: string, url: nil, type: NoteType.Photo.rawValue, data: NSKeyedArchiver.archivedData(withRootObject: images) as NSData?, album: selectedAlbum, tags: selectedTags)
        } else if let string = string {
            HSCoreDataManager.sharedManager.addNewNote(title: contentText, icon: nil, content: string, url: nil, type: NoteType.Words.rawValue, data: nil, album: selectedAlbum, tags: selectedTags)
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        print("OK")
        let albumItem = SLComposeSheetConfigurationItem()
        albumItem?.title = "待阅箱"
        albumItem?.tapHandler = {
            let bundlePath = Bundle.main.bundlePath.appending("/Base.lproj/")
            let configuretionVC = UIStoryboard(name: "MainInterface", bundle: Bundle(path: bundlePath)).instantiateViewController(withIdentifier: "ConfiguretionViewController") as? ConfiguretionViewController
            configuretionVC?.type = .Album
            configuretionVC?.didSelectAlbum = {(album) in
                self.selectedAlbum = album
                albumItem?.title = album?.name
            }
            self.pushConfigurationViewController(configuretionVC)
        }
        let tagItem = SLComposeSheetConfigurationItem()
        tagItem?.title = "标签"
        tagItem?.tapHandler = {
            let bundlePath = Bundle.main.bundlePath.appending("/Base.lproj/")
            let configuretionVC = UIStoryboard(name: "MainInterface", bundle: Bundle(path: bundlePath)).instantiateViewController(withIdentifier: "ConfiguretionViewController") as? ConfiguretionViewController
            configuretionVC?.type = .Tag
            configuretionVC?.didSelectTags = {(tags) in
                if tags.count > 0 {
                    self.selectedTags = tags
                    tagItem?.title = tags.reduce("") { (title, tag) -> String in
                        return title + (tag.name ?? "") + " "
                    }
                }
            }
            self.pushConfigurationViewController(configuretionVC)
        }
        
        return [albumItem, tagItem]
    }
    
    private func fetchItemData() {
        DispatchQueue.global(priority: .high).sync() { [weak self]() -> Void in
            if let providers = (self?.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments as? [NSItemProvider] {
                for provider in providers {
                    if let identifier = provider.registeredTypeIdentifiers.first as? String {
                        if UTTypeConformsTo(identifier as CFString, kUTTypeImage) {
                            provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                                if let fetchedUrl = item as? URL {
                                    self?.images.append(try! Data(contentsOf: fetchedUrl))
                                } else if let fetchedImage = item as? UIImage {
                                    let provider = fetchedImage.cgImage?.dataProvider
                                    if let data = provider?.data {
                                        self?.images.append(data as Data)
                                    }
                                } else if let fetchedData = item as? Data {
                                    self?.images.append(fetchedData)
                                }
                            })
                        } else if UTTypeConformsTo(identifier as CFString, kUTTypeAudio) {
                            provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                                if let fetchedUrl = item as? URL {
                                    self?.audioData = try? Data(contentsOf: fetchedUrl)
                                }
                            })
                        } else if UTTypeConformsTo(identifier as CFString, kUTTypePlainText) {
                            provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                                if let fetchedString = item as? String {
                                    self?.string = fetchedString
                                }
                            })
                        } else if UTTypeEqual(identifier as CFString, kUTTypeURL) {
                            provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                                self?.url = item as? URL
                            })
                        } else if UTTypeEqual(identifier as CFString, kUTTypeHTML) {
                            provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                                if let html = item as? String {
                                    self?.htmlData = Data(base64Encoded: html)
                                }
                            })
                        } else if UTTypeEqual(identifier as CFString, kUTTypeFileURL) {
                            provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                                if let fetchedUrl = item as? URL {
                                    if let data = try? Data(contentsOf: fetchedUrl) {
                                        switch (data as NSData).fileType {
                                        case is FileType.Image:
                                            self?.images.append(try! Data(contentsOf: fetchedUrl))
                                        case is FileType.Audio:
                                            self?.audioData = data
                                        default: break
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }

}












