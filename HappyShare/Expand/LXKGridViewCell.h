//
//  Created by 李现科 on 15/11/16.
//  Copyright © 2015年 李现科. All rights reserved.
//

// Abstract:
// A collection view cell that displays a thumbnail image.


@import UIKit;


@interface LXKGridViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *livePhotoBadgeImage;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end
