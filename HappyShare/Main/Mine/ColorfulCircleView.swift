//
//  ColorfulCircleView.swift
//  HappyShare
//
//  Created by 李现科 on 16/2/16.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit

@IBDesignable
class ColorfulCircleView: UIView {
    
    // 圆弧线宽
    @IBInspectable
    var lineWidth: CGFloat = 20.0
    
    // 圆弧半径
    @IBInspectable
    var radius: CGFloat = 120.0
    
    @IBInspectable
    var firstColor: UIColor = .red {
        didSet {
            
        }
    }
    
    @IBInspectable
    var secondColor: UIColor = .orange {
        didSet {
            
        }
    }
    
    @IBInspectable
    var thirdColor: UIColor = .yellow {
        didSet {
            
        }
    }
    
    @IBInspectable
    var forthColor: UIColor = .green {
        didSet {
            
        }
    }
    
    @IBInspectable
    var fifthColor: UIColor = .cyan {
        didSet {
            
        }
    }
    
    @IBInspectable
    var sixthColor: UIColor = .blue {
        didSet {
            
        }
    }
    
    @IBInspectable
    var firstPercentage: CGFloat = 0.0 {
        didSet {
            
        }
    }
    
    @IBInspectable
    var secondPercentage: CGFloat = 0.0 {
        didSet {
            
        }
    }
    
    @IBInspectable
    var thirdPercentage: CGFloat = 0.0 {
        didSet {
            
        }
    }
    
    @IBInspectable
    var forthPercentage: CGFloat = 0.0 {
        didSet {
            
        }
    }
    
    @IBInspectable
    var fifthPercentage: CGFloat = 0.0 {
        didSet {
            
        }
    }
    
    @IBInspectable
    var sixthPercentage: CGFloat = 0.0 {
        didSet {
            
        }
    }
        
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addArc(center: center, strokeStart: 0.0, strokeEnd: sixthPercentage, strokeColor: sixthColor, fillColor: UIColor.clear, shadowRadius: 0.0, shadowOpacity: 0.0, shadowOffsset: CGSize.zero)
        addArc(center: center, strokeStart: 0.0, strokeEnd: fifthPercentage, strokeColor: fifthColor, fillColor: UIColor.clear, shadowRadius: 0.0, shadowOpacity: 0.0, shadowOffsset: CGSize.zero)
        addArc(center: center, strokeStart: 0.0, strokeEnd: forthPercentage, strokeColor: forthColor, fillColor: UIColor.clear, shadowRadius: 0.0, shadowOpacity: 0.0, shadowOffsset: CGSize.zero)
        addArc(center: center, strokeStart: 0.0, strokeEnd: thirdPercentage, strokeColor: thirdColor, fillColor: UIColor.clear, shadowRadius: 0.0, shadowOpacity: 0.0, shadowOffsset: CGSize.zero)
        addArc(center: center, strokeStart: 0.0, strokeEnd: secondPercentage, strokeColor: secondColor, fillColor: UIColor.clear, shadowRadius: 0.0, shadowOpacity: 0.0, shadowOffsset: CGSize.zero)
        addArc(center: center, strokeStart: 0.0, strokeEnd: firstPercentage, strokeColor: firstColor, fillColor: UIColor.clear, shadowRadius: 0.0, shadowOpacity: 0.0, shadowOffsset: CGSize.zero)
    }
    
    /**
     
     - parameter center:        <#center description#>
     - parameter strokeStart:   <#strokeStart description#>
     - parameter strokeEnd:     <#strokeEnd description#>
     - parameter strokeColor:   <#strokeColor description#>
     - parameter fillColor:     <#fillColor description#>
     - parameter shadowRadius:  <#shadowRadius description#>
     - parameter shadowOpacity: <#shadowOpacity description#>
     - parameter shadowOffsset: <#shadowOffsset description#>
     */
    func addArc(center: CGPoint, strokeStart: CGFloat, strokeEnd: CGFloat, strokeColor: UIColor, fillColor: UIColor, shadowRadius: CGFloat, shadowOpacity: Float, shadowOffsset: CGSize) {
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: 40, startAngle: strokeStart + CGFloat(M_PI), endAngle: strokeEnd + CGFloat(M_PI), clockwise: true)
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        strokeColor.setStroke()
        fillColor.setFill()
        path.stroke()
        path.fill()
    }
    
}
