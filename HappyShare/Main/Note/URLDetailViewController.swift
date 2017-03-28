//
//  URLDetailViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/21.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class URLDetailViewController: NoteDetailViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: note?.url ?? "") {
            webView.loadRequest(URLRequest(url: url))
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        navigationItem.title = note?.title
        contentLabel.text = note?.content
    }

    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let url = NSURL(string: note?.url ?? "") else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.view.tintColor = tiffanyBlue
        navigationController?.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeURLNoteVC = segue.destination as? WriteURLNoteViewController, segue.identifier == "URLDetailVC -> WriteURLNoteVC" {
            writeURLNoteVC.note = note
        }
    }
    
}
