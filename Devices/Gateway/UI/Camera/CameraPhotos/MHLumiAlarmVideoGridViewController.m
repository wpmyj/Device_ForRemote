//
//  MHLumiAlarmVideoGridViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAlarmVideoGridViewController.h"
#import "MHLumiPhotoGridCollectionViewCell.h"
#import "MHLumiPhotoGridViewHeaderView.h"

#import "MHLumiAlarmVideoPreviewViewController.h"

//AVPlayerViewController
@interface MHLumiAlarmVideoGridViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MHLumiAlarmVideoPreviewViewControllerDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) MHLumiAlarmVideoPreviewViewController *alarmVideoPreviewViewController;
@end

@implementation MHLumiAlarmVideoGridViewController

- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device{
    self = [super initWithDevice:device];
    if (self){
        _cameraDevice = (MHDeviceCamera*)device;
        self.isHasMore = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame)-flowLayout.minimumInteritemSpacing*5)/4;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    [self.view addSubview:self.collectionView];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
    if (self.collectionView.contentSize.width > 0){
        UIEdgeInsets inset = self.collectionView.contentInset;
        inset = UIEdgeInsetsMake(64, 0, 0, 0);
        [self.collectionView setContentInset:inset];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.collectionView.contentSize.width > 0){
        UIEdgeInsets inset = self.collectionView.contentInset;
        inset = UIEdgeInsetsMake(64, 0, 0, 0);
        [self.collectionView setContentInset:inset];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.dataSource){
        return [self.dataSource numberOfSection];
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataSource){
        return [self.dataSource numberOfRowInSection:section];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MHLumiPhotoGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MHLumiPhotoGridCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    cell.identifierForAsset = indexPath.description;
    [cell setMediaType:PHAssetMediaTypeVideo];
    [self.dataSource fetchVImageOfItemAtIndexPath:indexPath completeHandler:^(UIImage *image) {
        if ([cell.identifierForAsset isEqualToString: indexPath.description]){
            cell.imageView.image = image;
        }
    }];
    [self.dataSource fetchVideoDurationAtIndexPath:indexPath completeHandler:^(NSTimeInterval duration) {
        if ([cell.identifierForAsset isEqualToString:indexPath.description]){
            [cell setDurationWithTimeInterval:duration];
        }
    }];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"kind = %@",kind);
    MHLumiPhotoGridViewHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[MHLumiPhotoGridViewHeaderView reuseIdentifier] forIndexPath:indexPath];
    headerView.titleLabel.text = [self.dataSource headerTitleInSection:indexPath.section];
    return headerView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndexPath = indexPath;
    [self.navigationController pushViewController:self.alarmVideoPreviewViewController animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 0, 8, 0);
}

- (void)reloadData{
    if (_collectionView){
        [self.collectionView reloadData];
    }
}

#pragma mark - MHLumiAlarmVideoPreviewViewControllerDataSource
- (void)alarmVideoPreviewViewController:(MHLumiAlarmVideoPreviewViewController *)alarmVideoPreviewViewController
                          fetchVideoUrl:(void (^)(NSString *, NSString *))fetchVideoUrlCompleteHandler{
    NSString *identifier = [self.dataSource fetchVideoUrlIdentifierAtIndexPath:self.selectedIndexPath];
    __weak typeof(self) weakself = self;
    [self.dataSource fetchvideoUrlAtIndexPath:weakself.selectedIndexPath completeHandler:^(NSString *videoUrl) {
        NSLog(@"传给播放VC的Url：%@",videoUrl);
        fetchVideoUrlCompleteHandler(videoUrl,identifier);
    }];
}

#pragma mark - setter and getter
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

- (CGSize)thumbnailSize{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    return CGSizeMake(size.width*scale, size.height*scale);
}

- (MHLumiAlarmVideoPreviewViewController *)alarmVideoPreviewViewController{
    if (!_alarmVideoPreviewViewController) {
        _alarmVideoPreviewViewController = [[MHLumiAlarmVideoPreviewViewController alloc] initWithCameraDevice:self.cameraDevice];
        _alarmVideoPreviewViewController.dataSource = self;
    }
    return _alarmVideoPreviewViewController;
}

@end
