//
//  TabBarController.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/16.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let viewControllers = viewControllers {
            for viewController in viewControllers {
                if viewController is UINavigationController {
                    viewController.view.backgroundColor = .white
                }
            }
        }
    }
}
