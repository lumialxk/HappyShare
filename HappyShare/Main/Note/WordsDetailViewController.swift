//
//  WordsDetailViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/18.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class WordsDetailViewController: NoteDetailViewController {
    
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeWordsNoteVC = segue.destination as? WriteWordsNoteViewController, segue.identifier == "WordsDetailVC -> WriteWordsVC" {
            writeWordsNoteVC.note = note
        }
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        navigationItem.title = note?.title
        contentTextView.text = note?.content ?? ""
    }
    
    // Target action
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let content = note?.content else {
            return
        }
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        activityVC.view.tintColor = tiffanyBlue
        navigationController?.present(activityVC, animated: true, completion: nil)
    }
}







