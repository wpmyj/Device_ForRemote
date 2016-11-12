//
//  MHLumiAssetPreviewViewController.m
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiAssetPreviewViewController.h"
#import <Photos/Photos.h>
#import "UIMHLumiAssetImagePreviewCollectionViewCell.h"
#import "UIMHLumiAssetVideoPreviewCollectionViewCell.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"

@interface MHLumiAssetPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIMHLumiAssetVideoPreviewCollectionViewCellDelegate,UIMHLumiAssetImagePreviewCollectionViewCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL hasSetDefaultIndexPath;
@property (nonatomic, strong) UIView *buttonsContanerView;
@property (nonatomic, strong) NSMutableArray *buttonArray; //大的那种控制按钮
/**
 *  分享按钮
 */
@property (nonatomic, strong) UIButton *cameraShareButton;

/**
 *  删除按钮
 */
@property (nonatomic, strong) UIButton *camerDeleteButton;
@property (nonatomic, strong) MASConstraint *buttonsContanerViewBottomConstraint;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation MHLumiAssetPreviewViewController
static NSString *kVideoCellReuseIdentifier = @"videoCellReuseIdentifier.MHLumiAssetPreviewViewController";
static NSString *kImageCellReuseIdentifier = @"imageCellReuseIdentifier.MHLumiAssetPreviewViewController";
static CGFloat kButtonsContanerViewHeight = 80;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = NO;
    _hasSetDefaultIndexPath = false;
    self.automaticallyAdjustsScrollViewInsets = NO;

}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = self.collectionView.frame.size;
    if (self.collectionView.frame.size.width > 0 && self.defaultIndexPath && !_hasSetDefaultIndexPath){
        [self.collectionView scrollToItemAtIndexPath:self.defaultIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _hasSetDefaultIndexPath = YES;
}

- (void)buildSubviews{
    [super buildSubviews];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.buttonsContanerView];
    [self.buttonsContanerView addSubview:self.camerDeleteButton];
    [self.buttonsContanerView addSubview:self.cameraShareButton];
    [self.buttonArray addObject:self.camerDeleteButton];
    [self.buttonArray addObject:self.cameraShareButton];
    [self configureLayoutWithOrientation:UIInterfaceOrientationPortrait];
}
#pragma mark - configureLayout
- (void)configureLayoutWithOrientation:(UIInterfaceOrientation)orientation{
    [self.buttonsContanerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kButtonsContanerViewHeight);
       self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view);
    }];
    
    UIButton *lastButton = nil;
    for (UIButton *button in self.buttonArray) {
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.buttonsContanerView);
            if (lastButton){
                make.left.equalTo(lastButton.mas_right);
            }else{
                make.left.equalTo(self.buttonsContanerView.mas_left);
            }
            make.width.mas_equalTo(self.buttonsContanerView.mas_width).multipliedBy(1.0/self.buttonArray.count);
        }];
        lastButton = button;
    }
}

#pragma mark - event response
- (void)cameraShareButtonAction:(UIButton *)sender{
    
}

- (void)cameraDeleteButtonAction:(UIButton *)sender{
    PHAsset *todoAsset = self.dateSource[self.selectedIndexPath.section][self.selectedIndexPath.item];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:@[todoAsset]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dateSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dateSource[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *todoAsset = self.dateSource[indexPath.section][indexPath.item];
    if (todoAsset.mediaType == PHAssetMediaTypeImage){
        UIMHLumiAssetImagePreviewCollectionViewCell *cell = (UIMHLumiAssetImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[UIMHLumiAssetImagePreviewCollectionViewCell imageCellReuseIdentifier] forIndexPath:indexPath];
        [cell configureCellWithAsset:todoAsset];
        cell.delegate = self;
        return cell;
    }else{
        UIMHLumiAssetVideoPreviewCollectionViewCell *cell = (UIMHLumiAssetVideoPreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[UIMHLumiAssetVideoPreviewCollectionViewCell videoCellReuseIdentifier] forIndexPath:indexPath];
        [cell configureCellWithAsset:todoAsset];
        cell.delegate = self;
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *todoAsset = self.dateSource[indexPath.section][indexPath.item];
    BOOL isHidden = self.navigationController.navigationBarHidden;
    if (todoAsset.mediaType == PHAssetMediaTypeImage){
        [self setHidesControlView:!isHidden];
    }else{
        [self setHidesControlView:!isHidden];
        if (isHidden){
            
        }else{
            
        }
        UIMHLumiAssetVideoPreviewCollectionViewCell *todoCell = (UIMHLumiAssetVideoPreviewCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        todoCell.playButton.hidden = NO;
        if (todoCell.isPlaying){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([collectionView.visibleCells containsObject:todoCell] && todoCell.isPlaying){
                    [UIView animateWithDuration:0.5 animations:^{
                        todoCell.playButton.alpha = 0;
                    } completion:^(BOOL finished) {
                        todoCell.playButton.hidden = YES;
                        todoCell.playButton.alpha = 1;
                    }];
                }
            });
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[UIMHLumiAssetVideoPreviewCollectionViewCell class]]){
       UIMHLumiAssetVideoPreviewCollectionViewCell *todoCell = (UIMHLumiAssetVideoPreviewCollectionViewCell *)cell;
        todoCell.playButton.hidden = NO;
        [todoCell playerViewPause];
    }else if ([cell isKindOfClass:[UIMHLumiAssetImagePreviewCollectionViewCell class]]){
        UIMHLumiAssetImagePreviewCollectionViewCell *todoCell = (UIMHLumiAssetImagePreviewCollectionViewCell *)cell;
        [todoCell resetCell];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndexPath = indexPath;
    PHAsset *todoAsset = self.dateSource[indexPath.section][indexPath.item];
    NSDateFormatter *dataFormatter = [NSDateFormatter timeLineDateFormatter];
    NSString *title = [dataFormatter stringFromDate:todoAsset.creationDate];
    self.navigationItem.title = title;
}


#pragma mark - UIMHLumiAssetVideoPreviewCollectionViewCellDelegate
- (void)videoPreviewCollectionViewCell:(UIMHLumiAssetVideoPreviewCollectionViewCell *)cell
                      didTapPlayButton:(UIButton *)button{
    if (cell.isPlaying){
        [cell playerViewPause];
    }else{
        [cell playerViewPlay];
        [self setHidesControlView:YES];
    }
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakself.collectionView.visibleCells containsObject:cell] && cell.isPlaying){
            [UIView animateWithDuration:0.5 animations:^{
                cell.playButton.alpha = 0;
            } completion:^(BOOL finished) {
                cell.playButton.hidden = YES;
                cell.playButton.alpha = 1;
            }];
        }
    });
}

- (void)videoPreviewCollectionViewCellPlayerViewEndToPlay:(UIMHLumiAssetVideoPreviewCollectionViewCell *)cell{
    cell.playButton.hidden = NO;
}

#pragma mark - UIMHLumiAssetImagePreviewCollectionViewCellDelegate
- (void)imagePreviewCollectionViewCellDidTap:(UIMHLumiAssetImagePreviewCollectionViewCell *)cell{
    BOOL isHidden = self.navigationController.navigationBarHidden;
    [self setHidesControlView:!isHidden];
}

- (void)imagePreviewCollectionViewCellWillZoom:(UIMHLumiAssetImagePreviewCollectionViewCell *)cell{
    [self setHidesControlView:YES];
}

#pragma mark - private function
- (void)setHidesControlView:(BOOL)hidesControlView{
    if (hidesControlView){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.buttonsContanerViewBottomConstraint uninstall];
        [self.buttonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view).mas_offset(kButtonsContanerViewHeight);
        }];
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.buttonsContanerView.hidden = YES;
        }];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.buttonsContanerViewBottomConstraint uninstall];
        [self.buttonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view);
        }];
        self.buttonsContanerView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

#pragma mark - getter ans setter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [cv registerClass:[UIMHLumiAssetImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:[UIMHLumiAssetImagePreviewCollectionViewCell imageCellReuseIdentifier]];
        [cv registerClass:[UIMHLumiAssetVideoPreviewCollectionViewCell class] forCellWithReuseIdentifier:[UIMHLumiAssetVideoPreviewCollectionViewCell videoCellReuseIdentifier]];
        cv.pagingEnabled = YES;
        cv.delegate = self;
        cv.dataSource = self;
        _collectionView = cv;
    }
    return _collectionView;
}

- (UIView *)buttonsContanerView{
    if (!_buttonsContanerView){
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
        _buttonsContanerView = aView;
    }
    return _buttonsContanerView;
}

- (UIButton *)cameraShareButton{
    if (!_cameraShareButton) {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(cameraShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_share"] forState:UIControlStateNormal];
        _cameraShareButton = button;
    }
    return _cameraShareButton;
}

- (UIButton *)camerDeleteButton{
    if (!_camerDeleteButton) {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(cameraDeleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_preview_delete"] forState:UIControlStateNormal];
        _camerDeleteButton = button;
    }
    return _camerDeleteButton;
}

- (NSMutableArray *)buttonArray{
    if (!_buttonArray){
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}
@end
