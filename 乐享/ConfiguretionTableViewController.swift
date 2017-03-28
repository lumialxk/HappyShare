//
//  ConfiguretionTableViewController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/20.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

enum ConfiguretionType {
    case album
    case tag
}

class ConfiguretionViewController: UIViewController {
    
    var type: ConfiguretionType?
    var didSelectAlbum:((_ album: Album?) -> Void)?
    var didSelectTags:((_ tags: [Tag]) -> Void)?
    
    fileprivate let cellIdentifier = "itemCell"
    fileprivate var selectedTags = [Tag]()
    fileprivate var selectedAlbum: Album?
    fileprivate let tags = HSCoreDataManager.sharedManager.allTags(byHot: true)
    fileprivate let albums = HSCoreDataManager.sharedManager.allAlbums()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
    }
    
    private func configureSubviews() {
        if type == .album {
            navigationItem.title = "请选择合辑"
            navigationItem.rightBarButtonItem = nil
        }
        if type == .tag {
            navigationItem.title = "请选择标签"
        }
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func complete(_ sender: UIBarButtonItem) {
        
        didSelectTags?(selectedTags)
        _ = navigationController?.popViewController(animated: true)
    }
    
    
}

extension ConfiguretionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return type == ConfiguretionType.album ? albums?.count ?? 0 : tags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = type == ConfiguretionType.album ? albums?[indexPath.row].name : tags?[indexPath.row].name
        cell.textLabel?.textColor = UIColor.darkGray
        if type == ConfiguretionType.tag {
            if let tag = tags?[indexPath.row] {
                cell.accessoryType = selectedTags.contains(tag) ? .checkmark : .none
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
}

extension ConfiguretionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == ConfiguretionType.album {
            didSelectAlbum?(albums?[indexPath.row])
            _ = navigationController?.popViewController(animated: true)
        } else {
            if let tag = tags?[indexPath.row] {
                if selectedTags.contains(tag) {
                    selectedTags.remove(at: selectedTags.index(of: tag)!)
                } else {
                    selectedTags.append(tag)
                }
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
}














