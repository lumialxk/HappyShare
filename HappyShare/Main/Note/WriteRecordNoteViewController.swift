//
//  WriteRecordNoteViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/25.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class WriteRecordNoteViewController: WriteNoteViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    private let textViewPlaceholder = "请输入备注"
    fileprivate let audioSession = AVAudioSession.sharedInstance()
    private var recorder: AVAudioRecorder?
    private let recordUrl: URL? = {
        var url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last
        url?.appendPathComponent("records.caf")
        return url
    }()
    private var dynamicRecorder: AVAudioRecorder? {
        get {
            if recorder == nil {
                let settings = [AVFormatIDKey:NSNumber(value: kAudioFormatMPEG4AAC), AVSampleRateKey:44100, AVNumberOfChannelsKey:2]
                recorder = try? AVAudioRecorder(url: recordUrl!, settings: settings)
                recorder?.prepareToRecord()
            }
            return recorder
        }
        set {
            recorder = newValue
        }
    }
    private var player: AVAudioPlayer?
    private var dynamicPlayer: AVAudioPlayer? {
        get {
            if player == nil {
                if let data = note?.data {
                    player = try? AVAudioPlayer(data: data as Data)
                } else {
                    player = try? AVAudioPlayer(contentsOf: recordUrl!)
                }
                player?.prepareToPlay()
            }
            return player
        }
        set {
            player = newValue
        }
    }
    private lazy var timer: Timer = {
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(WriteRecordNoteViewController.timerUpdate), userInfo: nil, repeats: true)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(WriteRecordNoteViewController.textViewDidBeginEdit), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WriteRecordNoteViewController.textViewDidEndEdit), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        _ = try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        _ = try? audioSession.setActive(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        _ = try? audioSession.setActive(false)
    }

    private func configureSubviews() {
        titleTextField.text = note?.title
        if let content = note?.content {
            contentTextView.text = content
        } else {
            contentTextView.text = textViewPlaceholder
            contentTextView.textColor = UIColor.lightGray
        }
        playButton.isEnabled = false
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func play(_ sender: UIButton) {
        if recorder != nil {
            recorder?.stop()
            recorder = nil
        }
        if dynamicPlayer?.currentTime == 0 {
            progressView.setProgress(0.0, animated: false)
        }
        recordButton.isEnabled = false
        if dynamicPlayer?.isPlaying == true {
            dynamicPlayer?.pause()
            timer.fireDate = Date.distantFuture
            sender.setTitle("播放", for: .normal)
        } else {
            dynamicPlayer?.play()
            timer.fireDate = Date.distantPast
            sender.setTitle("暂停", for: .normal)
        }
    }
    
    @IBAction func record(_ sender: UIButton) {
        // 检查权限并试图获取
        switch audioSession.recordPermission() {
        case AVAudioSessionRecordPermission.denied:
            showAuthorizeAlertView(notice: "乐享 没有使用麦克风的权限,\n如果设置权限,请点击设置\n并启用麦克风",sender: self)
            return
        case AVAudioSessionRecordPermission.undetermined:
            audioSession.requestRecordPermission { (permited) -> Void in
                if permited {
                    self.record(sender)
                }
            }
            return
        default: break
        }
        dynamicPlayer?.stop()
        dynamicPlayer = nil
        guard let recorder = dynamicRecorder else {
            return
        }
        if recorder.isRecording {
            recorder.pause()
            playButton.isEnabled = true
            timer.fireDate = Date.distantFuture
            sender.setTitle("录制", for: .normal)
        } else {
            recorder.record()
            playButton.isEnabled = false
            timer.fireDate = Date.distantPast
            progressView.setProgress(0.0, animated: true)
            sender.setTitle("暂停", for: .normal)
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        recorder?.stop()
        recorder?.deleteRecording()
        progressView.setProgress(0.0, animated: false)
        timeLabel.text = "0.0s"
        playButton.isEnabled = false
        recordButton.isEnabled = true
    }
    
    func timerUpdate() {
        if player?.isPlaying == true {
            updatePlayTime()
        } else if recorder?.isRecording == true {
            updateRecordTime()
        } else {
            playButton.setTitle("播放", for: .normal)
            timer.fireDate = Date.distantFuture
        }
    }
    
    func updatePlayTime() {
        timeLabel.text = String(format: "%.1f/%.1f", arguments: [player?.currentTime ?? 0.0,player?.duration ?? 0.0])
        progressView.setProgress(player?.currentTime &/ player?.duration, animated: true)
        print(dynamicPlayer?.currentTime)
    }
    
    func updateRecordTime() {
        timeLabel.text = String(format: "%.1fs", arguments: [recorder?.currentTime ?? 0.0])
        progressView.setProgress(1.0, animated: false)
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

// MARK: - AVAudioRecorderDelegate
extension WriteRecordNoteViewController: AVAudioRecorderDelegate {
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        _ = try? audioSession.setActive(false)
    }
    
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {
        _ = try? audioSession.setActive(true)
    }
}

// MARK: - AVAudioPlayerDelegate
extension WriteRecordNoteViewController: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//        progressView.setProgress(0.0, animated: false)
//        playButton.setTitle("播放", forState: .Normal)
//        timeLabel.text = String(format: "0.0/%.1f", arguments: [dynamicPlayer?.duration ?? 0.0])
//    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        _ = try? audioSession.setActive(false)
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        _ = try? audioSession.setActive(true)
    }
}

infix operator &/
func &/(lhs: Double?,rhs: Double?) -> Float {
    guard let lhs = lhs,let rhs = rhs, lhs != 0.0 && rhs != 0.0 else {
        return 0.0
    }
    return Float(lhs/rhs)
}


















