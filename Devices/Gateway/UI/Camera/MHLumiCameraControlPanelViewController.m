//
//  MHLumiCameraControlPanelViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiCameraControlPanelViewController.h"
#import "MHLumiUICameraHomeViewController.h"
#import "MHLumiUICameraGatewayViewController.h"
#import "MHLumiCameraDeviceListViewController.h"
#import "MHLumiCameraScenesListViewController.h"
#import "MHGatewayDisclaimerViewController.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewayExtraSceneManager.h"
#import "MHGatewayDisclaimerView.h"
#import "MHLumiLocalCacheManager.h"
#import "MHLumiUITool.h"
#import "MHColorUtils.h"
@interface MHLumiCameraControlPanelViewController()<MHLumiUICameraHomeViewControllerDelegate,MHLumiCameraDeviceListViewControllerDelegate>
@property (nonatomic, strong) MHLumiUICameraHomeViewController *homeVC;
@property (nonatomic, strong) MHLumiUICameraGatewayViewController *homeVC1;
@property (nonatomic, strong) MHLumiCameraScenesListViewController *homeVC2;
@property (nonatomic, strong) MHLumiCameraDeviceListViewController *homeVC3;
@property (nonatomic, strong) MHGatewayDisclaimerView *disclaimerView;
@property (nonatomic, strong) NSArray<UIViewController *> * vcArray;

@property (nonatomic, strong) UIView *buttonsContanerView;
@property (nonatomic, strong) UIButton *cameraHomeButton;
@property (nonatomic, strong) UIButton *gatewayButton;
@property (nonatomic, strong) UIButton *scenesButton;
@property (nonatomic, strong) UIButton *deviceButton;
@property (nonatomic, strong) UIView *lineForButtonsContanerView;
@property (nonatomic, strong) NSArray <UIButton *> * buttonArray;
@property (nonatomic, assign) BOOL isLandscapeRight;
@property (nonatomic, assign) BOOL isDisclaimerShown;
@property (nonatomic, strong) MASConstraint *buttonsContanerViewBottomConstraint;
@property (nonatomic, strong) MHLumiLocalCacheManager *defaultIndexManager;
@property (nonatomic, copy) NSString *keyForDefaultIndexManager;
@property (nonatomic, strong) NSObject *devListManagerObserver;
@end

@implementation MHLumiCameraControlPanelViewController
static CGFloat kBottomToolbarHeight = 50;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:_devListManagerObserver];
}

- (id)initWithDevice:(MHDevice *)device{
    self = [super initWithDevice:device];
    if (self){
        _cameraDevice = (MHDeviceCamera*)device;
        
        //获取本地记录最后一次打开的index
        self.keyForDefaultIndexManager = [NSString stringWithFormat:@"MHLumiCamera_defaultIndex_%@",_cameraDevice.did];
        NSNumber *index = (NSNumber *)[self.defaultIndexManager objectForKey:self.keyForDefaultIndexManager];
        if (index){
            _selectIndex = index.integerValue%self.vcArray.count;
        }else{
            _selectIndex = 0;
        }
        _isLandscapeRight = NO;
    }
    return self;
}

#pragma mark - view life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = YES;
    [self getOtherStatus];
    XM_WS(weakself);
    self.devListManagerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[[MHDevListManager sharedManager] notificationNameForUIUpdate] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakself.homeVC3 startRefresh];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![self isDisclaimerShown]) {
        self.isDisclaimerShown = YES;
        [self showDisclaimer];
    }else{
        [self checkVersion];
    }
}

- (BOOL)isAllowedToCheckUpgrade{
    return [self isDisclaimerShown];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    if (self.vcArray.count <= 0){
        return UIStatusBarStyleLightContent;
    }
    if (self.vcArray[_selectIndex]){
         return [self.vcArray[_selectIndex] preferredStatusBarStyle];
    }
    return UIStatusBarStyleLightContent;
}


#pragma mark - MHLumiCameraDeviceListViewControllerDelegate
- (void)cameraDeviceListViewControllerCallWhenDeviceCountChange:(MHLumiCameraDeviceListViewController *)cameraDeviceListViewController{
    [self.homeVC1 reBuildSubviews];
}

#pragma mark - MHLumiUICameraHomeViewControllerDelegate
- (void)homeViewControllerDidOnRecording:(MHLumiUICameraHomeViewController *)homeViewController{
    [self setButtonsContanerViewHidden:YES animation:0.2];
}

- (void)homeViewControllerDidOffRecording:(MHLumiUICameraHomeViewController *)homeViewController{
    if (!_isLandscapeRight){
        [self setButtonsContanerViewHidden:NO animation:0.2];
    }
}

- (void)homeViewController:(MHLumiUICameraHomeViewController *)homeViewController shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (!_isLandscapeRight){
        _isLandscapeRight = YES;
        [self setButtonsContanerViewHidden:YES animation:0.3];
        [self rotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight withAnimation:0.3];
    }else{
        _isLandscapeRight = NO;
        [self setButtonsContanerViewHidden:NO animation:0.3];
        [self rotateToInterfaceOrientation:UIInterfaceOrientationPortrait withAnimation:0.3];
    }
}

- (void)homeViewController:(MHLumiUICameraHomeViewController *)homeViewController
    willHiddenControlPanel:(BOOL)hidden
              withDuration:(NSTimeInterval)duration{
    if (!_isLandscapeRight && !hidden){
        [self setButtonsContanerViewHidden:NO animation:duration];
    }else if (hidden){
        [self setButtonsContanerViewHidden:YES animation:duration];
    }
}

- (UIInterfaceOrientation)homeViewControllerCurrentInterfaceOrientation:(MHLumiUICameraHomeViewController *)homeViewController{
    if (_isLandscapeRight){
        return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}

#pragma mark - private function
- (void)redrawNavigationBarWithIndex:(NSInteger)index {
    
    UIImage* leftImage = [[UIImage imageNamed:@"navi_back_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if(index == [self.vcArray indexOfObject:self.homeVC1] || index == [self.vcArray indexOfObject:self.homeVC]) {
        leftImage = [[UIImage imageNamed:@"navi_back_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    if(self.cameraDevice.shareFlag == MHDeviceUnShared && index == [self.vcArray indexOfObject:self.homeVC]){
        [self.navigationItem setRightBarButtonItems:@[]];
        UIImage* imageMore = [[UIImage imageNamed:@"navi_more_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *rightItemMore = [[UIBarButtonItem alloc] initWithImage:imageMore
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self action:@selector(onMore:)];
        self.navigationItem.rightBarButtonItem = rightItemMore;
    }else if (index == [self.vcArray indexOfObject:self.homeVC2]){
        UIBarButtonItem *addDeviceBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.homeVC2.btnAddDevice];
        UIBarButtonItem *scenesLogBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.homeVC2.btnSetting];
        [self.navigationItem setRightBarButtonItems:@[addDeviceBarButton, scenesLogBarButton] animated:NO];
    }else if (index == [self.vcArray indexOfObject:self.homeVC3] && self.cameraDevice.shareFlag != MHDeviceShared){
        [self.navigationItem setRightBarButtonItems:@[]];
        UIBarButtonItem *addDeviceBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.homeVC3.btnAddDevice];
        self.navigationItem.rightBarButtonItem = addDeviceBarButton;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
        [self.navigationItem setRightBarButtonItems:@[]];
    }

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:leftImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - 处理横屏和竖屏
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation withAnimation:(NSTimeInterval)duration{
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:duration animations:^{
            self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.navigationController.view.bounds = CGRectMake(0, 0, screenHeight, screenWidth);
        }];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        [UIView animateWithDuration:duration animations:^{
            self.navigationController.view.transform = CGAffineTransformIdentity;
            self.navigationController.view.bounds = CGRectMake(0, 0, screenWidth, screenHeight);
        }];

    }
}

#pragma mark - 底部按钮隐藏和显示
- (void)setButtonsContanerViewHidden:(BOOL)hidden animation:(NSTimeInterval)animation{
    if (hidden) {
        [self.buttonsContanerViewBottomConstraint uninstall];
        [self.buttonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view).mas_offset(kBottomToolbarHeight);
        }];
        [UIView animateWithDuration:animation animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.buttonsContanerView.hidden = YES;
        }];
    }else{
        [self.buttonsContanerViewBottomConstraint uninstall];
        [self.buttonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view);
        }];
        self.buttonsContanerView.hidden = NO;
        [UIView animateWithDuration:animation animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

#pragma mark - 免责声明（直接从MHGatewayMainViewController 复制过来的，有空再修理）
- (MHGatewayDisclaimerView *)disclaimerView{
    if (!_disclaimerView){
        XM_WS(weakself);
        MHGatewayDisclaimerView *todoView = [[MHGatewayDisclaimerView alloc] initWithFrame:self.view.bounds panelFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200) withCancel:^(id v) {
            [weakself.navigationController popViewControllerAnimated:YES];
        } withOk:^(id v) {
            [weakself.disclaimerView hideWithAnimation:YES];
            [weakself setDisclaimerShown:YES];
            weakself.isDisclaimerShown = NO;
            [weakself checkVersion];
        }];
        todoView.onOpenDisclaimerPage = ^(void){
            [weakself openDisclaimerPage];
        };
        todoView.isExitOnClickBg = NO;
        _disclaimerView = todoView;
    }
    return _disclaimerView;
}

#define keyForDisclaimer @"keyForDisclaimer"
- (void)openDisclaimerPage {
    XM_WS(weakself);
    MHGatewayDisclaimerViewController* disclaimerVC = [[MHGatewayDisclaimerViewController alloc] init];
    disclaimerVC.onBack = ^{
        [weakself.disclaimerView showPanelWithAnimation:NO];
    };
    [self.navigationController pushViewController:disclaimerVC animated:YES];
    [self.disclaimerView hideWithAnimation:NO];
}

-(void)showDisclaimer {
    [[UIApplication sharedApplication].keyWindow addSubview:self.disclaimerView];
}

-(BOOL)isDisclaimerShown {
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     keyForDisclaimer,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(flag){
        return [flag boolValue];
    }
    return NO;
}

-(void)setDisclaimerShown:(BOOL)shown {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     keyForDisclaimer,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [NSNumber numberWithBool:shown];
    [defaults setObject:flag forKey:key];
    [defaults synchronize];
}

#pragma mark - check version
- (void)checkVersion{
    [self.cameraDevice versionControl:^(NSInteger retcode) {
        if (retcode == -2){
            [self onDeviceUpgradePage];
        }
    }];
}

- (void)getOtherStatus {
    XM_WS(weakself);
    __block MHSafeDictionary *tempDic = [[MHSafeDictionary alloc] init];
    [self.cameraDevice.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL *stop) {
        sensor.parent = weakself.cameraDevice;
        NSString *name = sensor.name;
        [tempDic setObject:name forKey:sensor.did];
    }];
    //网关时间可能did是网关的did导致取不到子设备名字
    [tempDic setObject:@"小米多功能网关" forKey:self.cameraDevice.did];
    self.cameraDevice.logManager.deviceNames = tempDic;
    
    if([self.cameraDevice laterV3Gateway]){
        [[MHGatewayBindSceneManager sharedInstance] fetchBindSceneList:self.cameraDevice withSuccess:nil];
        [[MHGatewayExtraSceneManager sharedInstance] fetchExtraMapTableWithSuccess:nil failure:nil];
    }
}


#pragma mark - event response
- (void)toolbarButtonAction:(UIButton *)sender{
    NSInteger tag = sender.tag % 4;
    [self setSelectVCWithIndex:tag];
    self.buttonArray[_selectIndex].selected = NO;
    self.buttonArray[tag].selected = YES;
    _selectIndex = tag;
    [self.defaultIndexManager setObject:[NSNumber numberWithInteger:_selectIndex] forKey:self.keyForDefaultIndexManager];
    [self redrawNavigationBarWithIndex:_selectIndex];
}

- (void)onBack{
    //不移除关系，小米的基类会干傻事
    for (UIViewController *vc in self.vcArray) {
        [vc removeFromParentViewController];
    }
    
    if (_isLandscapeRight){
        [self rotateToInterfaceOrientation:UIInterfaceOrientationPortrait withAnimation:0];
    }
    
    if (self.vcArray && self.vcArray[_selectIndex]){
        [((MHViewController *)self.vcArray[_selectIndex]) onBack];
    }else{
        [super onBack];
    }
}

- (void)onMore:(id)sender{
    UIViewController *todoVC = self.vcArray[_selectIndex];
    if ([todoVC respondsToSelector:@selector(onMore:)] && [todoVC isKindOfClass:[MHLuDeviceViewControllerBase class]]) {
        [(MHLuDeviceViewControllerBase *)todoVC onMore:sender];
    }else{
        [self onMore:sender];
    }
}

#pragma mark - buildSubviews
- (void)buildSubviews{
    [super buildSubviews];
    [self.view addSubview:self.buttonsContanerView];
    self.buttonArray = @[self.cameraHomeButton, self.gatewayButton, self.scenesButton, self.deviceButton];
    for (UIButton *button in self.buttonArray) {
        [self.buttonsContanerView addSubview:button];
    }
    [self.buttonsContanerView addSubview:self.lineForButtonsContanerView];
    self.buttonArray[_selectIndex].selected = YES;
    self.vcArray = @[self.homeVC,self.homeVC1,self.homeVC2,self.homeVC3];
    [self setSelectVCWithIndex:_selectIndex];
    [self redrawNavigationBarWithIndex:_selectIndex];
    [self configureLayout];
}

#pragma mark - configureLayout
- (void)configureLayout{
    [self.buttonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kBottomToolbarHeight);
        self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view);
    }];
    
    UIButton *lastButton = nil;
    for (UIButton *button in self.buttonArray) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.buttonsContanerView);
            make.width.equalTo(self.buttonsContanerView).multipliedBy(1.0/self.buttonArray.count);
            if (lastButton){
                make.left.equalTo(lastButton.mas_right);
            }else{
                make.left.equalTo(self.buttonsContanerView);
            }
        }];
        lastButton = button;
    }
    
    [self.lineForButtonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.top.left.right.equalTo(self.buttonsContanerView);
    }];
}

- (void)setSelectVCWithIndex:(NSInteger)index{
    UIViewController *todoVC = self.vcArray[index];
    if (_selectIndex == index && todoVC.view.superview){
        return;
    }
    [self.vcArray[_selectIndex].view removeFromSuperview];
    [self.vcArray[_selectIndex] removeFromParentViewController];
    if (todoVC.parentViewController == nil){
        [self addChildViewController:todoVC];
        [todoVC didMoveToParentViewController:self];
    }
    [self.view addSubview:todoVC.view];
    [todoVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.buttonsContanerView.mas_top);
    }];
}

#pragma mark - setter and getter

- (UIButton *)cameraHomeButton{
    if (!_cameraHomeButton){
        UIButton *button = [self configureBarButtonWithTitle:@"摄像头" tag:0];
        _cameraHomeButton = button;
    }
    return _cameraHomeButton;
}

- (UIButton *)gatewayButton{
    if (!_gatewayButton){
        UIButton *button = [self configureBarButtonWithTitle:@"网关" tag:1];
        _gatewayButton = button;
    }
    return _gatewayButton;
}

- (UIButton *)scenesButton{
    if (!_scenesButton){
        UIButton *button = [self configureBarButtonWithTitle:@"自动化" tag:2];
        _scenesButton = button;
    }
    return _scenesButton;
}

- (UIButton *)deviceButton{
    if (!_deviceButton){
        UIButton *button = [self configureBarButtonWithTitle:@"设备" tag:3];
        _deviceButton = button;
    }
    return _deviceButton;
}

- (UIView *)lineForButtonsContanerView{
    if (!_lineForButtonsContanerView) {
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
        _lineForButtonsContanerView = aView;
    }
    return _lineForButtonsContanerView;
}

- (UIButton *)configureBarButtonWithTitle:(NSString *)title tag:(NSInteger)tag{
    UIButton *button = [[UIButton alloc] init];
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[MHColorUtils colorWithRGB:0x17B56C] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(toolbarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[UIImage imageNamed:@"lumi_camera_barbutton_bg_unselected"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"lumi_camera_barbutton_bg_unselected"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:@"lumi_camera_barbutton_bg"] forState:UIControlStateSelected];
    [button sizeToFit];
    return button;
}

- (UIView *)buttonsContanerView{
    if (!_buttonsContanerView){
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [UIColor whiteColor];
        _buttonsContanerView = aView;
    }
    return _buttonsContanerView;
}

- (MHLumiUICameraHomeViewController *)homeVC{
    if (!_homeVC){
        _homeVC = [[MHLumiUICameraHomeViewController alloc] initWithCameraDevice:_cameraDevice];
        _homeVC.isNavBarTranslucent = YES;
        _homeVC.delegate = self;
    }
    return _homeVC;
}

- (MHLumiUICameraGatewayViewController *)homeVC1{
    if (!_homeVC1){
        _homeVC1 = [[MHLumiUICameraGatewayViewController alloc] initWithSensor:self.cameraDevice];
    }
    return _homeVC1;
}

- (MHLumiCameraScenesListViewController *)homeVC2{
    if (!_homeVC2){
        _homeVC2 = [[MHLumiCameraScenesListViewController alloc] initWithDevice:self.cameraDevice];
    }
    return _homeVC2;
}

- (MHLumiCameraDeviceListViewController *)homeVC3{
    if (!_homeVC3){
        MHLumiCameraDeviceListViewController *vc = [[MHLumiCameraDeviceListViewController alloc] initWithDevice:self.cameraDevice];
        vc.delegate = self;
        _homeVC3 = vc;
    }
    return _homeVC3;
}

- (MHLumiLocalCacheManager *)defaultIndexManager{
    if (!_defaultIndexManager){
        _defaultIndexManager = [[MHLumiLocalCacheManager alloc] initWithType:MHLumiLocalCacheManagerCommon andIdentifier:[MHPassportManager sharedSingleton].currentAccount.userId];
    }
    return _defaultIndexManager;
}
@end
