//
//  WriteWordsNoteViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/16.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class WriteWordsNoteViewController: WriteNoteViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    private let textViewPlaceholder = "请输入正文"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(WriteWordsNoteViewController.textViewDidBeginEdit), name: Notification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WriteWordsNoteViewController.textViewDidEndEdit), name: Notification.Name.UITextViewTextDidEndEditing, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextViewTextDidEndEditing, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureSubviews() {
        titleTextField.text = note?.title
        if let content = note?.content {
            contentTextView.text = content
        } else {
            contentTextView.text = textViewPlaceholder
            contentTextView.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - Target action
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let note = note {
            HSCoreDataManager.sharedManager.modifyNote(note: note, title: titleTextField.text, icon: nil, content: contentTextView.text, url: "http://www.baidu.com", type: NoteType.Words.rawValue, data: nil, album: selectedAlbum, tags: selectedTags)
        } else {
            HSCoreDataManager.sharedManager.addNewNote(title: titleTextField.text, icon: nil, content: contentTextView.text, url: "http://www.baidu.com", type: NoteType.Words.rawValue, data: nil, album: selectedAlbum, tags: selectedTags)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func textViewDidBeginEdit(notification: NSNotification) {
        if let textView = notification.object as? UITextView, textView.text == textViewPlaceholder {
            textView.text = nil
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEdit(notification: NSNotification) {
        if let textView = notification.object as? UITextView, textView.text.lengthOfBytes(using: String.Encoding.utf8) == 0 {
            textView.text = textViewPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }

}


















