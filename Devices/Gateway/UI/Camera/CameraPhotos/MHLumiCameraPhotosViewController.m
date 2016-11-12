//
//  MHLumiCameraPhotosViewController.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/25.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiCameraPhotosViewController.h"
#import "MHLumiCameraMediaDataManager.h"
#import "MHLumiPhotoGridViewController.h"
#import "MHLumiCameraPhotosNavHeaderView.h"


@interface MHLumiCameraPhotosViewController()<PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) NSArray<UIButton *> *navButtons;
@property (nonatomic, strong) NSArray<NSString *> *navButtontitles;
@property (nonatomic, strong) UIView *navTitleView;
@property (nonatomic, strong) MHLumiPhotoGridViewController *photoGridViewController;
@property (nonatomic, strong) MHLumiCameraMediaDataManager *cameraMediaDataManager;
@end


@implementation MHLumiCameraPhotosViewController

- (void)dealloc{
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
#pragma mark - view life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = NO;
    _currentIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)onBack{
    //不移除关系，小米的基类会干傻事
    [self.photoGridViewController removeFromParentViewController];
    [super onBack];
}

- (void)buildSubviews{
    [super buildSubviews];
    [self setupSubViews];
}

- (void)setupSubViews{
    UIImage* leftImage = [[UIImage imageNamed:@"navi_back_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:leftImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    MHLumiCameraPhotosNavHeaderView *titleBGView = [[MHLumiCameraPhotosNavHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
//    titleBGView.backgroundColor = [UIColor greenColor];
    self.navigationItem.titleView = titleBGView;
    CGFloat navTitleViewWidth = 0;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat buttonWidth = screenWidth / (self.navButtons.count + 2);
    for (NSInteger index = 0; index < self.navButtons.count ; index ++) {
        UIButton *todoButton = self.navButtons[index];
        [self.navTitleView addSubview:todoButton];
        todoButton.frame = CGRectMake(index*buttonWidth, 0, buttonWidth, 44);
        navTitleViewWidth += buttonWidth;
    }
    self.navTitleView.frame = CGRectMake((screenWidth - navTitleViewWidth)/2, 0, navTitleViewWidth, 44);
//    self.navTitleView.backgroundColor = [UIColor redColor];
    [titleBGView setCenterView:self.navTitleView];
    
    self.photoGridViewController.dateSource = [self.cameraMediaDataManager fetchDataWithType:[self currentType]];
    [self addChildViewController:self.photoGridViewController];
    [self.photoGridViewController didMoveToParentViewController:self];
    [self.view addSubview:self.photoGridViewController.view];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoGridViewController.dateSource = [self.cameraMediaDataManager fetchDataWithType:[self currentType]];
        [self.photoGridViewController reloadData];
    });
}

#pragma mark - private function
- (MHLumiCameraMediaDataType)currentType{
   return [self cameraMediaDataTypeWithIndex:_currentIndex];
}

- (MHLumiCameraMediaDataType)cameraMediaDataTypeWithIndex:(NSInteger)index{
    MHLumiCameraMediaDataType type = MHLumiCameraMediaDataTypeAll;
    switch (index) {
        case 0:
            type = MHLumiCameraMediaDataTypeAll;
            break;
        case 1:
            type = MHLumiCameraMediaDataTypeAlarm;
            break;
        case 2:
            type = MHLumiCameraMediaDataTypePhotoWithoutAlarm;
            break;
        case 3:
            type = MHLumiCameraMediaDataTypeVideoWithoutAlarm;
            break;
        default:
            break;
    }
    return type;
}
#pragma mark - event response
- (void)navButtonAction:(UIButton *)sender{
    if (sender.tag == _currentIndex){
        return;
    }
    NSInteger todoIndex = 0;
    for (UIButton *button in self.navButtons) {
        if (button == sender){
            NSLog(@"tag=%@, selected",button.currentTitle);
            button.selected = YES;
            todoIndex = button.tag;
        }else{
            NSLog(@"tag=%@, ;",button.currentTitle);
            button.selected = NO;
        }
    }
    _currentIndex = todoIndex;
    self.photoGridViewController.dateSource = [self.cameraMediaDataManager fetchDataWithType:[self currentType]];
    [self.photoGridViewController reloadData];
}

#pragma mark - getter and setter
- (NSArray<NSString *> *)navButtontitles{
    if (!_navButtontitles) {
        _navButtontitles = @[@"全部",@"报警",@"照片",@"视频"];
    }
    return _navButtontitles;
}

- (NSArray<UIButton *> *)navButtons{
    if (!_navButtons) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.navButtontitles.count];
        for (NSInteger index = 0; index < self.navButtontitles.count; index ++) {
            UIButton *aButton = [[UIButton alloc] init];
            aButton.tag = index;
            [aButton setTitle:self.navButtontitles[index] forState:UIControlStateNormal];
            [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [aButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
            [aButton addTarget:self action:@selector(navButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            aButton.selected = index == _currentIndex;
            [array addObject:aButton];
        }
        _navButtons = array;
    }
    return _navButtons;
}

- (UIView *)navTitleView{
    if (!_navTitleView) {
        _navTitleView = [[UIView alloc] init];
    }
    return _navTitleView;
}

- (MHLumiPhotoGridViewController *)photoGridViewController{
    if (!_photoGridViewController) {
        _photoGridViewController = [[MHLumiPhotoGridViewController alloc] init];
    }
    return _photoGridViewController;
}

- (MHLumiCameraMediaDataManager *)cameraMediaDataManager{
    if (!_cameraMediaDataManager) {
//        PHFetchResult *topLevelUserCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHAssetCollection *assetCollection = [MHLumiCameraMediaDataManager lumiCameraAssetCollection];
//        [topLevelUserCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            PHAssetCollection * todoAssetCollection = (PHAssetCollection *)obj;
//            if ([todoAssetCollection.localizedTitle isEqualToString:@"绿米摄像头"]){
//                assetCollection = todoAssetCollection;
//                *stop = YES;
//            }
//        }];
        _cameraMediaDataManager = [[MHLumiCameraMediaDataManager alloc] initWithAssetCollection:assetCollection];
    }
    return _cameraMediaDataManager;
}
@end
