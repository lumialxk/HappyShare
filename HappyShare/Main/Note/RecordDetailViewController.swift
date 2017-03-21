//
//  RecordDetailViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/25.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class RecordDetailViewController: NoteDetailViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var playButton: UIButton!
    
    private let audioSession = AVAudioSession.sharedInstance()

    private var player: AVAudioPlayer?
    private lazy var playTimer: Timer = {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordDetailViewController.updatePlayTime), userInfo: nil, repeats: true)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = note?.data {
            player = try? AVAudioPlayer(data: data as Data)
        }
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        timeLabel.text = String(format: "%.1fs", arguments: [player?.duration ?? 0.0])
        titleLabel.text = note?.title
        contentTextView.text = note?.content
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func play(_ sender: UIButton) {
        guard let player = player else {
            return
        }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        
    }
    
    func updatePlayTime() {
        
    }
    
}
