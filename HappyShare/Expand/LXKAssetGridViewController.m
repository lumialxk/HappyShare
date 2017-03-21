//
//  Created by 李现科 on 15/11/16.
//  Copyright © 2015年 李现科. All rights reserved.
//

// Abstract:
// A view controller displaying a grid of assets.


#import "LXKAssetGridViewController.h"

#import "LXKGridViewCell.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"

@import PhotosUI;

@interface LXKAssetGridViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) NSMutableArray<NSString *> *selectedAssetIdentifiers;

@property CGRect previousPreheatRect;

@end


@implementation LXKAssetGridViewController

static NSString * const CellReuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;

- (void)awakeFromNib {
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    
    
    
    [self resetCachedAssets];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Determine the size of the thumbnails to request from the PHCachingImageManager
	CGFloat scale = [UIScreen mainScreen].scale;
	CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
	AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);

    // Add button to the navigation bar if the asset collection supports adding content.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.collectionView reloadData];
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
}

#pragma mark - Target action

- (IBAction)back:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(didDismissViewController)]) {
        [self.delegate didDismissViewController];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)choose:(UIBarButtonItem *)sender {
    __weak LXKAssetGridViewController *wself = self;
    if ([self.delegate respondsToSelector:@selector(didChoosePhotos:)]) {
        if (self.selectedAssetIdentifiers.count == 0) {
            [self.delegate didChoosePhotos:nil];
            return;
        }
        NSMutableArray<NSData *> *photos = [NSMutableArray array];
        PHFetchResult *fetchResults = [PHAsset fetchAssetsWithLocalIdentifiers:self.selectedAssetIdentifiers options:nil];
        [fetchResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = obj;
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            requestOptions.networkAccessAllowed = NO;
            [wself.imageManager requestImageDataForAsset:asset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (downloadFinined) {
                    [photos addObject:imageData];
                    if (idx == fetchResults.count-1) {
                        [wself.imageManager stopCachingImagesForAllAssets];
                        [wself.delegate didChoosePhotos:photos];
                        [wself dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
        Change notifications may be made on a background queue. Re-dispatch to the
        main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            /*
                Tell the collection view to animate insertions and deletions if we
                have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
        
        [self resetCachedAssets];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.assetsFetchResults[indexPath.item];

    
    // Dequeue an AAPLGridViewCell.
    LXKGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    cell.representedAssetIdentifier = asset.localIdentifier;
    
    if ([self.selectedAssetIdentifiers containsObject:cell.representedAssetIdentifier]) {
        cell.livePhotoBadgeImage = [UIImage imageNamed:@"btn_right"];
    } else {
        cell.livePhotoBadgeImage = nil;
    }

    // Request an image for the asset from the PHCachingImageManager.
    [self.imageManager requestImageForAsset:asset
								 targetSize:AssetGridThumbnailSize
								contentMode:PHImageContentModeAspectFill
									options:nil
							  resultHandler:^(UIImage *result, NSDictionary *info) {
        // Set the cell's thumbnail image if it's still showing the same asset.
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            cell.thumbnailImage = result;
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LXKGridViewCell *cell = (LXKGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.selectedAssetIdentifiers containsObject:cell.representedAssetIdentifier]) {
        [self.selectedAssetIdentifiers removeObject:cell.representedAssetIdentifier];
    } else {
        [self.selectedAssetIdentifiers addObject:cell.representedAssetIdentifier];
    }
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
											targetSize:AssetGridThumbnailSize
										   contentMode:PHImageContentModeAspectFill
											   options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
										   targetSize:AssetGridThumbnailSize
										  contentMode:PHImageContentModeAspectFill
											  options:nil];

        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

- (NSMutableArray<NSString *> *)selectedAssetIdentifiers {
    if (!_selectedAssetIdentifiers) {
        _selectedAssetIdentifiers = [NSMutableArray array];
    }
    return _selectedAssetIdentifiers;
}

@end


