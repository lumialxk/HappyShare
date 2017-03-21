//
//  Created by 李现科 on 15/11/16.
//  Copyright © 2015年 李现科. All rights reserved.
//

// Abstract:
// A view controller displaying a grid of assets.


@import UIKit;
@import Photos;

@protocol LXKPhotoPickerDelegate <NSObject>
@optional
- (void)didChoosePhotos:(NSMutableArray<NSData *> *)photos;
- (void)didDismissViewController;

@end

static NSString *const storyboardIdentifier = @"LXKAssetGridViewController";

@interface LXKAssetGridViewController : UICollectionViewController

@property (nonatomic, assign) id<LXKPhotoPickerDelegate> delegate;

@end
