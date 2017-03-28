//
//  WriteURLNoteViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/25.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class WriteURLNoteViewController: WriteNoteViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var webView: UIWebView!
    
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
        albumButton.setTitle(selectedAlbum?.name, for: .normal)
        titleTextField.text = note?.title
        contentTextField.text = note?.content
        if let url = URL(string: note?.url ?? "") {
            webView.loadRequest(URLRequest(url: url))
        }
    }

    // 保存
    @IBAction func save(_ sender: UIBarButtonItem) {
        HSCoreDataManager.sharedManager.modifyNote(note: note, title: titleTextField.text, icon: note?.icon, content: contentTextField.text, url: note?.url, type: NoteType.URL.rawValue, data: note?.data, album: selectedAlbum, tags: selectedTags)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
}

