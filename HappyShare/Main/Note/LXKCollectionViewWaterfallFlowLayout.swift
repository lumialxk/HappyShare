//
//  LXKCollectionViewWaterfallFlowLayout.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/28.
//  Copyright © 2016年 李现科. All rights reserved.
//

import UIKit


class LXKCollectionViewWaterfallFlowLayout: UICollectionViewLayout {
    
    var lineNumber = 3 // defualt
    var rowSpacing: CGFloat = 10.0 // default
    var lineSpacing: CGFloat = 10.0 // default
    var sectionInset = UIEdgeInsetsMake(10, 10, 10, 10) // default
    var cellHeightAtIndex: ((IndexPath,CGFloat) -> CGFloat)?
    private var cellWidth: CGFloat {
        get {
            return (kScreenWidth - rowSpacing * CGFloat(lineNumber - 1) - sectionInset.left - sectionInset.right) / CGFloat(lineNumber)
        }
    }
    private var lineHeights = [Int : CGFloat]()
    private var allLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        let maxLineHeight = lineHeights.reduce(CGFloat.leastNormalMagnitude) {
            $0 < $1.1 ? $1.1 : $0
        }
        return CGSize(width: collectionView!.bounds.width, height: maxLineHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        super.prepare()
        lineHeights.removeAll()
        allLayoutAttributes.removeAll()
        for section in 0..<lineNumber {
            lineHeights.updateValue(sectionInset.top, forKey: section)
        }
        for row in 0..<collectionView!.numberOfItems(inSection: 0) {
            allLayoutAttributes.append(layoutAttributesForItem(at: IndexPath(item: row, section: 0))!)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if let height = cellHeightAtIndex?(indexPath, cellWidth) {
            let minLineHeight = lineHeights.reduce((0,CGFloat.greatestFiniteMagnitude)) {
                $0.1 > $1.1 ? ($1.0,$1.1) : ($0.0,$0.1)
            }
            let frame = CGRect(x: sectionInset.left + CGFloat(minLineHeight.0) * (cellWidth + rowSpacing), y: minLineHeight.1, width: cellWidth, height: height)
            layoutAttributes.frame = frame
            lineHeights.updateValue(frame.height + lineSpacing + minLineHeight.1, forKey: minLineHeight.0)
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return allLayoutAttributes
    }
    
    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        for index in 0..<allLayoutAttributes.count {
            if allLayoutAttributes[index].frame.contains(position) {
                return IndexPath(item: index, section: 0)
            }
        }
        return IndexPath(item: allLayoutAttributes.count-1, section: 0)
    }
    
    
}

extension CGSize {
    // 以固定宽度等比缩放
    func compatibleHeight(withWidth width: CGFloat) -> CGFloat{
        guard width > 0.0 else {
            return 0.0
        }
        let scale = self.width / width
        return self.height / scale
    }
}
