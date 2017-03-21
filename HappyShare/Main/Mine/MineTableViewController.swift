//
//  MineTableViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/15.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class MineTableViewController: UITableViewController {

    @IBOutlet weak var passwordEnableSwitch: UISwitch!
    @IBOutlet weak var touchIDEnableSwitch: UISwitch!
    @IBOutlet weak var totalSizeLabel: UILabel!
    
    var passwordDidPass: ((String?, Bool) -> Void)?
    private var type: PasswordType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let enterPasswordVC = segue.destination as? EnterPasswordViewController, segue.identifier == "MineTVC -> EnterPasswordVC" {
            enterPasswordVC.passwordDidPass = passwordDidPass
            enterPasswordVC.type = type
        }
    }
    
    private func configureSubviews() {
        passwordEnableSwitch.setOn(UserDefaults.standard.bool(forKey: kEnablePassword), animated: false)
        touchIDEnableSwitch.setOn(UserDefaults.standard.bool(forKey: kEnableTouchID), animated: false)
        if let filePath = FileManager.default.url(forUbiquityContainerIdentifier: groupIdentifier)?.appendingPathComponent("\(fileName).sqlite"){
            print("\(FileManager.default.fileExists(atPath: filePath.absoluteString))")
            if let fileDictionary = try? FileManager.default.attributesOfItem(atPath: filePath.absoluteString) {
                let fileTotalSize = (fileDictionary as NSDictionary).fileSize()
                totalSizeLabel.text = String(format: "%.2fM", arguments: [Double(fileTotalSize) / 1024.0 / 1024.0])
            }
        }
    }
    
    @IBAction func enablePassword(_ sender: UISwitch) {
        if UserDefaults.standard.bool(forKey: kEnablePassword) {
            type = .Enter
        } else {
            type = .New
        }
        passwordDidPass = {[weak self](password, success) in
            if success {
                if UserDefaults.standard.bool(forKey: kEnablePassword) {
                    UserDefaults.standard.set(false, forKey: kEnablePassword)
                    UserDefaults.standard.set(false, forKey: kEnableTouchID)
                    self?.touchIDEnableSwitch.setOn(false, animated: true)
                } else {
                    UserDefaults.standard.set(true, forKey: kEnablePassword)
                    UserDefaults.standard.set(password?.md5, forKey: kMD5Password)
                }
                self?.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
            } else {
                sender.setOn(!sender.isOn, animated: true)
            }
        }
        performSegue(withIdentifier: "MineTVC -> EnterPasswordVC", sender: self)
    }
    
    @IBAction func enableTouchID(_ sender: UISwitch) {
        autherTouchID { (success, error) -> Void in
            if success {
                UserDefaults.standard.set(sender.isOn, forKey: kEnableTouchID)
                UserDefaults.standard.synchronize()
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    sender.setOn(!sender.isOn, animated: true)
                })
            }
        }
    }
    
    
    
}

// MARK: - UITableViewDataSource
extension MineTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && UserDefaults.standard.bool(forKey: kEnablePassword) == false {
            return 1
        }
        return 2
    }
    
}

// MARK: - UITableViewDelegate
extension MineTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
