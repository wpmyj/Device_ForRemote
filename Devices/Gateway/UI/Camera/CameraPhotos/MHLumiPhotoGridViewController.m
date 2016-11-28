//
//  MHLumiPhotoGridViewController.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/24.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiPhotoGridViewController.h"
#import "MHLumiPhotoGridCollectionViewCell.h"
#import "UICollectionView+MHLumiHelper.h"
#import "MHLumiPhotoGridViewHeaderView.h"
#import "MHLumiAssetPreviewViewController.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"

@interface MHLumiPhotoGridViewController()<PHPhotoLibraryChangeObserver,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) CGRect preRect;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSMutableArray<NSString *> *headerTitles;
@end

@implementation MHLumiPhotoGridViewController
- (void)dealloc{
    [self resetCache];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - view life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = NO;
    _preRect = CGRectZero;
    self.view.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame)-flowLayout.minimumInteritemSpacing*5)/4;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    [self.view addSubview:self.collectionView];

}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.dataSource){
        return self.dataSource.count;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataSource){
        return self.dataSource[section].count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MHLumiPhotoGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MHLumiPhotoGridCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    PHAsset *asset = self.dataSource[indexPath.section][indexPath.item];
    if (asset){
        cell.identifierForAsset = asset.localIdentifier;
        [self.imageManager requestImageForAsset:asset targetSize:[self thumbnailSize]  contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if ([cell.identifierForAsset isEqualToString:asset.localIdentifier]){
                cell.imageView.image = result;
                [cell setMediaType:asset.mediaType];
                if (asset.mediaType == PHAssetMediaTypeVideo){
                    [cell setDurationWithTimeInterval:asset.duration];
                }
            }
        }];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"kind = %@",kind);
    MHLumiPhotoGridViewHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[MHLumiPhotoGridViewHeaderView reuseIdentifier] forIndexPath:indexPath];
//    NSDate *date = self.dataSource[indexPath.section][0].creationDate;
    headerView.titleLabel.text = self.headerTitles[indexPath.section];
    return headerView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(photoGridViewController:didSelectItemAtIndexPath:)]){
        [self.delegate photoGridViewController:self didSelectItemAtIndexPath:indexPath];
    }else{
        MHLumiAssetPreviewViewController *vc = [[MHLumiAssetPreviewViewController alloc] init];
        vc.dateSource = self.dataSource;
        vc.defaultIndexPath = indexPath;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 0, 8, 0);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateCache];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    if (!self.fetchResult){
        return;
    }
    PHFetchResultChangeDetails *detail = [changeInstance changeDetailsForFetchResult:self.fetchResult];
    if (detail){
        self.fetchResult = detail.fetchResultAfterChanges;
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (detail.hasIncrementalChanges || detail.hasMoves){
                [weakself.collectionView reloadData];
                return ;
            }
            if (detail.insertedIndexes){
                [weakself.collectionView insertItemsAtIndexPaths:[self indexSetToIndexPathWithSection:0 indexSet:detail.insertedIndexes]];
            }
            
            if (detail.removedIndexes){
                [weakself.collectionView deleteItemsAtIndexPaths:[self indexSetToIndexPathWithSection:0 indexSet:detail.insertedIndexes]];
            }
            
            if (detail.changedIndexes){
                [weakself.collectionView reloadItemsAtIndexPaths:[self indexSetToIndexPathWithSection:0 indexSet:detail.insertedIndexes]];
            }
        });
        [self resetCache];
    }
}

#pragma mark - event response


#pragma mark - private function
- (void)reloadData{
    if (_collectionView){
        self.headerTitles = nil;
        [self.collectionView reloadData];
    }
}

- (NSArray<NSIndexPath *> *)indexSetToIndexPathWithSection:(NSInteger)section indexSet:(NSIndexSet *)set{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:set.count];
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return array;
}

- (void)resetCache{
    [self.imageManager stopCachingImagesForAllAssets];
    self.preRect = CGRectZero;
}

- (void)updateCache{
    if (![self isViewLoaded] || self.view.window == nil){
        return;
    }
    CGRect cvRect = self.collectionView.bounds;
    CGRect newRect = CGRectInset(cvRect, 0, -CGRectGetHeight(cvRect)/2);
    if (ABS(CGRectGetMidY(newRect)-CGRectGetMidY(self.preRect)) < CGRectGetHeight(cvRect)/3){
        return;
    }
    NSMutableArray<NSIndexPath *>* addIndexPaths = [NSMutableArray array];
    NSMutableArray<NSIndexPath *>* removeIndexPaths = [NSMutableArray array];
    [self computeDifferenceWithOldRect:self.preRect andNewRect:newRect withRemoveHandler:^(CGRect removeRect) {
        NSArray<NSIndexPath *> *todoIndexPaths = [self.collectionView indexPathsForElementsInRect:removeRect];
        [removeIndexPaths addObjectsFromArray:todoIndexPaths];
    } withAddHandler:^(CGRect addRect) {
        NSArray<NSIndexPath *> *todoIndexPaths = [self.collectionView indexPathsForElementsInRect:addRect];
        [addIndexPaths addObjectsFromArray:todoIndexPaths];
    }];
    [self printsIndexPath:addIndexPaths header:@"add"];
    [self printsIndexPath:removeIndexPaths header:@"remove"];
    NSArray<PHAsset *> *needCachAssets = [self fetchAssetsFormIndexPaths:addIndexPaths];
    NSArray<PHAsset *> *stopCachAssets =[self fetchAssetsFormIndexPaths:removeIndexPaths];
    [self.imageManager startCachingImagesForAssets:needCachAssets targetSize:[self thumbnailSize] contentMode:PHImageContentModeAspectFit options:nil];
    [self.imageManager stopCachingImagesForAssets:stopCachAssets targetSize:[self thumbnailSize] contentMode:PHImageContentModeAspectFit options:nil];
    self.preRect = newRect;
    NSLog(@"%@",NSStringFromCGRect(self.preRect));
}

- (NSArray<PHAsset *> *)fetchAssetsFormIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    if (self.dataSource && self.dataSource.count > 0){
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:indexPaths.count];
        for (NSIndexPath *indexPath in indexPaths) {
            PHAsset *asset = self.dataSource[indexPath.section][indexPath.item];
            [array addObject:asset];
        }
        return array;
    }
    return [NSArray array];
}

- (void)computeDifferenceWithOldRect:(CGRect)oldRect
                          andNewRect:(CGRect)newRect
                   withRemoveHandler:(void(^)(CGRect))removeHandler
                      withAddHandler:(void(^)(CGRect))addHandler{
    if (CGRectIntersectsRect(oldRect, newRect)){
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat x = newRect.origin.x;
        CGFloat width = newRect.size.width;
        if (oldMinY > newMinY){
            CGRect rect = CGRectMake(x, newMinY, width, oldMinY-newMinY);
            addHandler(rect);
        }
        
        if (oldMinY < newMinY){
            CGRect rect = CGRectMake(x, oldMinY, width, newMinY-oldMinY);
            removeHandler(rect);
        }
        
        if (oldMaxY < newMaxY){
            CGRect rect = CGRectMake(x, oldMaxY, width, newMaxY-oldMaxY);
            addHandler(rect);
        }
        
        if (oldMaxY > newMaxY){
            CGRect rect = CGRectMake(x, newMaxY, width, oldMaxY-newMaxY);
            removeHandler(rect);
        }
    }else{
        removeHandler(oldRect);
        addHandler(newRect);
    }
}

- (void)printsIndexPath:(NSArray<NSIndexPath *> *)indexPaths header:(NSString *)header{
    NSMutableString *string = [NSMutableString stringWithString:header];
    [string appendString:@": "];
    for (NSIndexPath *indexPath in indexPaths) {
        [string appendString:[NSString stringWithFormat:@"s: %ld, r: %ld",(long)indexPath.section,indexPath.row]];
    }
    NSLog(@"%@",string);
}

#pragma mark - getter and setter

- (PHCachingImageManager *)imageManager{
    if (!_imageManager){
        PHCachingImageManager *manager = [[PHCachingImageManager alloc] init];
        manager.allowsCachingHighQualityImages = YES;
        _imageManager = manager;
    }
    return _imageManager;
}

- (UICollectionView *)collectionView{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1;
        layout.headerReferenceSize = CGSizeMake(0, 30);
        UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        cv.backgroundColor = [UIColor whiteColor];
        cv.bounces = YES;
        cv.dataSource = self;
        cv.delegate = self;
        [cv registerClass:[MHLumiPhotoGridViewHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[MHLumiPhotoGridViewHeaderView reuseIdentifier]];
        [cv registerClass:[MHLumiPhotoGridCollectionViewCell class] forCellWithReuseIdentifier:[MHLumiPhotoGridCollectionViewCell reuseIdentifier]];
        _collectionView = cv;
    }
    return _collectionView;
}

-(NSMutableArray<NSString *> *)headerTitles{
    if (!_headerTitles) {
        NSMutableArray<NSString *> * titles = [NSMutableArray array];
        NSDateFormatter *dateFormatter = [NSDateFormatter timeLineDateFormatter];
        for (NSMutableArray<PHAsset *> *array in self.dataSource) {
            NSString *str = [dateFormatter stringFromDate:array[0].creationDate];
            [titles addObject:[str substringToIndex:10]];
        }
        _headerTitles = titles;
    }
    return _headerTitles;
}

- (CGSize)thumbnailSize{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    return CGSizeMake(size.width*scale, size.height*scale);
}

@end
