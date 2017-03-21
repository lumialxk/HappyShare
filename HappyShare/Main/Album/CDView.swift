//
//  CDView.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/25.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

class CDView: UIImageView {
    
    private var imageView: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addMask()
    }
    
    private func addMask() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        let length = bounds.height
        let bezierPath = UIBezierPath(ovalIn: CGRect(x: length / 5.0, y: length / 5.0, width: length / 5.0 * 3.0, height: length / 5.0 * 3.0))
        shapeLayer.lineWidth = length / 5 * 1.6
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = tiffanyBlue.cgColor
        shapeLayer.strokeColor = UIColor.darkGray.cgColor
        layer.addSublayer(shapeLayer)
    }
    
}
