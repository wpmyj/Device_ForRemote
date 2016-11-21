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
#import "MHLumiAssetPreviewViewController.h"
#import "MHLumiAlarmVideoGridViewController.h"

@interface MHLumiCameraPhotosViewController()<PHPhotoLibraryChangeObserver,MHLumiPhotoGridViewControllerDelegate,MHLumiAlarmVideoDataSourceDelegate>
@property (nonatomic, strong) NSArray<UIButton *> *navButtons;
@property (nonatomic, strong) NSArray<NSString *> *navButtontitles;
@property (nonatomic, strong) UIView *navTitleView;
@property (nonatomic, strong) MHLumiPhotoGridViewController *photoGridViewController;
@property (nonatomic, strong) MHLumiAlarmVideoGridViewController *alarmVideoGridViewController;
@property (nonatomic, strong) MHLumiAlarmVideoDataSource *alarmVideoDataSource;
@property (nonatomic, strong) MHLumiCameraMediaDataManager *cameraMediaDataManager;
@end


@implementation MHLumiCameraPhotosViewController

- (void)dealloc{
    NSLog(@"%@ VC析构了",self.description);
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device{
    self = [super initWithDevice:device];
    if (self){
        _cameraDevice = (MHDeviceCamera*)device;
        self.isHasMore = NO;
    }
    return self;
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

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (self.photoGridViewController.view.superview == self.view){
        self.photoGridViewController.view.frame = self.view.frame;
    }
    
    if (self.alarmVideoGridViewController.view.superview == self.view){
        self.alarmVideoGridViewController.view.frame = self.view.frame;
    }
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
    [titleBGView setCenterView:self.navTitleView];
    
    [self didSelectNavButtonAtIndex:_currentIndex];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself currentType] == MHLumiCameraMediaDataTypeAlarm){
            return ;
        }
        weakself.photoGridViewController.dataSource = [weakself.cameraMediaDataManager fetchDataWithType:[weakself currentType]];
        [weakself.photoGridViewController reloadData];
    });
}

+ (PHAuthorizationStatus)authorizationStatus{
    return [PHPhotoLibrary authorizationStatus];
}

+ (void)requestAuthorization:(void (^)(PHAuthorizationStatus))handler{
    [PHPhotoLibrary requestAuthorization:handler];
}

#pragma mark - MHLumiAlarmVideoDataSourceDelegate
- (void)alarmVideoDataSourceDidUpdate:(MHLumiAlarmVideoDataSource *)AlarmVideoDataSource withError:(NSError *)error{
    if (error){
        
    }else{
        [self.alarmVideoGridViewController reloadData];
    }
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
    [self didSelectNavButtonAtIndex:todoIndex];
}

- (void)didSelectNavButtonAtIndex:(NSInteger)index{
    _currentIndex = index;
    UIViewController *toRemoveVC = nil;
    UIViewController *toAddVC = nil;
    
    if ([self currentType] == MHLumiCameraMediaDataTypeAlarm){
        toRemoveVC = self.photoGridViewController;
        toAddVC = self.alarmVideoGridViewController;
        if (self.alarmVideoDataSource == nil){
            MHLumiAlarmVideoRequest *request = [[MHLumiAlarmVideoRequest alloc] init];
            self.alarmVideoDataSource = [[MHLumiAlarmVideoDataSource alloc] initWithReques:request];
            self.alarmVideoDataSource.delegate = self;
        }
        self.alarmVideoGridViewController.dataSource = self.alarmVideoDataSource;
    }else{
        toRemoveVC = self.alarmVideoGridViewController;
        toAddVC = self.photoGridViewController;
        self.photoGridViewController.dataSource = [self.cameraMediaDataManager fetchDataWithType:[self currentType]];
        [self.photoGridViewController reloadData];
    }
    
    if (toAddVC.parentViewController != self){
        [self addChildViewController:toAddVC];
        [toAddVC didMoveToParentViewController:self];
        [self.view addSubview:toAddVC.view];
    }
    
    if (toRemoveVC.parentViewController != nil){
        [toRemoveVC removeFromParentViewController];
        [toRemoveVC.view removeFromSuperview];
    }
    
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
        _photoGridViewController.delegate = self;
    }
    return _photoGridViewController;
}

- (MHLumiAlarmVideoGridViewController *)alarmVideoGridViewController{
    if (!_alarmVideoGridViewController) {
        _alarmVideoGridViewController = [[MHLumiAlarmVideoGridViewController alloc] initWithCameraDevice:self.cameraDevice];
    }
    return _alarmVideoGridViewController;
}

- (MHLumiCameraMediaDataManager *)cameraMediaDataManager{
    if (!_cameraMediaDataManager) {
        PHAssetCollection *assetCollection = [MHLumiCameraMediaDataManager lumiCameraAssetCollection];
        _cameraMediaDataManager = [[MHLumiCameraMediaDataManager alloc] initWithAssetCollection:assetCollection];
    }
    return _cameraMediaDataManager;
}
@end
