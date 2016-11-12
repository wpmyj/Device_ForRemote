//
//  MHCameraMainViewController.m
//  MiHome
//
//  Created by ayanami on 8/20/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHCameraMainViewController.h"
#import "MHGatewayTabView.h"
#import "MHACPartnerControlViewController.h"
#import "MHACPartnerDeviceListViewController.h"
#import "MHACPartnerSceneListViewController.h"
#import "MHDeviceCamera.h"
#import "MHGatewayMainpageAnimation.h"
#import "MHCCVideoViewController.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewayExtraSceneManager.h"
#import "MHLumiTUTKClient.h"
#import "MHLumiNeAACDecoder.h"
#import "MHLumiGLKViewController.h"
#import "MHLumiYUVBufferHelper.h"
#import <ffmpegWrapper/MHVideoFrameYUV.h>
#import <ffmpegWrapper/MHEAGLView.h>
#import "PlayAudio.h"
#import <AVFoundation/AVFoundation.h>
#import "libavcodec/avcodec.h"
@interface MHCameraMainViewController ()<MHLumiTUTKClientDelegate>

@property (nonatomic, strong) MHLumiTUTKClient *lumiTUTKClient;
@property (nonatomic, strong) MHLumiNeAACDecoder *lumiNeAACDecoder;
@property (nonatomic, strong) MHLumiGLKViewController *glkViewController;
@property (nonatomic, strong) PlayAudio *audioPlayer;

@property (nonatomic, strong) MHDeviceCamera *camera;
@property (nonatomic, strong) MHACPartnerControlViewController *controlView;
@property (nonatomic, strong) MHACPartnerSceneListViewController *sceneList;
@property (nonatomic, strong) MHACPartnerDeviceListViewController *deviceList;
@property (nonatomic, strong) MHCCVideoViewController *videoControl;
@property (nonatomic, strong) UIViewController *oldVC;
@property (nonatomic, strong) MHGatewayTabView *tabView;
@property (nonatomic, strong) MHGatewayMainpageAnimation *animationTool;
@property (nonatomic, strong) MHEAGLView *eaglView;

@property (nonatomic, assign) BOOL isAudioPlay;
@end

@implementation MHCameraMainViewController
-(id)initWithDevice:(MHDevice *)device {
    if(self = [super initWithDevice:device]) {
        self.camera = (MHDeviceCamera*)device;
        _isAudioPlay = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isNavBarTranslucent = YES;
    [self loadStatus];
    [self getOtherStatus];
    [self initTUTKClient];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self redrawNavigationBar];
    //    if (![self isDisclaimerShown]) {
    //        _isShowingDisclaimer = YES;
    //        [self showDisclaimer];
    //    }
    
    //    [_deviceList startRefresh];
    //    [_sceneList loadIFTTTRecords];
    //    [self startRefresh];
    [self checkVersion];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.eaglView enterForeground];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[MHTipsView shareInstance] hide];
}

- (void)dealloc{
    [_lumiTUTKClient deinitConnection];
    [self stopAudioPlay];
    [_audioPlayer reset];
//    avcodec_free_frame(&_todoFrame);
    NSLog(@"%@ 析构了",self.description);
}

- (void)initTUTKClient{
    XM_WS(ws);
    [[MHTipsView shareInstance] showTips:@"开始获取UDID" modal:NO];
    [self.camera getUidSuccess:^(NSString *udid, NSString *password) {
        XM_SS(ss,ws);
        [[MHTipsView shareInstance] showTips:@"开始setVideoWithOnOff" modal:NO];
        [ws.camera setVideoWithOnOff:YES uid:udid success:^(BOOL currentOnOrOff) {
            MHLumiTUTKConfiguration *cfg = [MHLumiTUTKConfiguration defaultConfiguration];
            cfg.udid = udid;
            ss.lumiTUTKClient = [[MHLumiTUTKClient alloc] initWithConfiguration:cfg];
            ss.lumiTUTKClient.delegate = ws;
            [[MHTipsView shareInstance] showTips:@"开始initConnectionWithCompletedHandler" modal:NO];
            [ss.lumiTUTKClient initConnectionWithCompletedHandler:^(MHLumiTUTKClient *client, int retCode) {
                if (retCode < 0){
                    [[MHTipsView shareInstance] showFailedTips:@"initConnectionWithCompletedHandler 失败" duration:2 modal:YES];
                    return;
                }
                NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:client.avChannelId];
                [[MHTipsView shareInstance] showTips:@"开始startVideoStreamWithJsonString" modal:NO];
                [client startVideoStreamWithJsonString:jsonStr startRequestData:YES completedHandler:^(MHLumiTUTKClient *client, int retCode) {
                    if (retCode < 0){
                        [[MHTipsView shareInstance] showFailedTips:@"startVideoStreamWithJsonString 失败" duration:2 modal:YES];
                        return;
                    }else{
                        [[MHTipsView shareInstance] showFinishTips:@"连接完成" duration:1 modal:YES];
                    }
                }];
            }];
        } failure:^(NSError *error) {
            [[MHTipsView shareInstance] showFailedTips:@"setVideoWithOnOff 失败" duration:2 modal:YES];
        }];
        
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showFailedTips:@"getUidSuccess 失败" duration:2 modal:YES];
    }];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    XM_WS(weakself);
    CGFloat w = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat h = w/1280.0*720;
    self.eaglView = ({
        MHEAGLView *eaglView = [[MHEAGLView alloc] initWithFrame:CGRectMake(0, 64, w ,h ) ];
        [eaglView setOpaque:YES];
        [eaglView setDataSize:1280.0 andHeight:720.0];
        [self.view addSubview:eaglView];
        eaglView;
    });
    
    
    CGRect tabRect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 0.6, 44);
    NSArray *tabTitleArray = @[
                               @{ @"name" : @"摄像头",
                                  @"color" : [UIColor colorWithWhite:1.f alpha:1.f] } ,
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title5", @"plugin_gateway", "网关"),
                                  @"color" : [UIColor colorWithWhite:1.f alpha:1.f] } ,
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title2", @"plugin_gateway", nil) ,
                                  @"color" : [MHColorUtils colorWithRGB:0x25bba4] } ,
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title3", @"plugin_gateway", nil) ,
                                  @"color" : [MHColorUtils colorWithRGB:0x25bba4] } ,
                               ];
    _tabView = [[MHGatewayTabView alloc] initWithFrame:tabRect
                                            titleArray:tabTitleArray
                                             stypeType:LumiTabStyleInTitle
                                              callback:^(NSInteger idx) {
                                                  [weakself onTabClicked:idx];
                                              }];
    
    self.navigationItem.titleView = _tabView;
    
    
    
    //动画
    _animationTool = [[MHGatewayMainpageAnimation alloc] init];
    _animationTool.homeVC = self;
    _animationTool.subViewArray = @[self.videoControl.view, self.controlView.view,self.sceneList.view,self.deviceList.view];
    [_animationTool homeVCAddGestureRecognizer];
    _animationTool.leftAnimationEndCallBack = ^(){
        [weakself onBack:nil];
    };
    _animationTool.onClickCurrentIndex = ^(NSInteger index){
        [weakself.tabView selectItem:index];
    };
}


#pragma mark - tab view clicked 切换view
- (void)onTabClicked:(NSInteger)index {
    switch (index) {
        case 0:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.videoControl];
            
            break;
        case 1:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.controlView];
            
            break;
        case 2:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.sceneList];
            
            break;
        case 3:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.deviceList];
            
            break;
        default:
            break;
    }
    _animationTool.currentIndex = index;
    [self redrawNavigationBar];
}


- (UIViewController *)moveControllerFrom:(UIViewController *)fromVC to:(UIViewController *)toVC {
    if (fromVC == toVC) {
        NSLog(@"相同的操作返回");
        return fromVC;
    }
    [self addChildViewController:toVC];
    [fromVC willMoveToParentViewController:nil];
    [self.view addSubview:toVC.view];
    toVC.view.hidden = NO;
    fromVC.view.hidden = YES;
    [fromVC removeFromParentViewController];
    [toVC didMoveToParentViewController:self];
    [fromVC.view removeFromSuperview];
    
    return toVC;
}

- (MHACPartnerControlViewController *)controlView {
    //    XM_WS(weakself);
    if (!_controlView) {
        //控制
        _controlView = [[MHACPartnerControlViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:self.camera];
    }
    return _controlView;
}

- (MHACPartnerSceneListViewController *)sceneList {
    //    XM_WS(weakself);
    if (!_sceneList) {
        //自动化
        _sceneList = [[MHACPartnerSceneListViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:self.camera];
        
    }
    return _sceneList;
}


- (MHACPartnerDeviceListViewController *)deviceList {
    XM_WS(weakself);
    if (!_deviceList) {
        //设备列表
        _deviceList = [[MHACPartnerDeviceListViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:self.camera];
        _deviceList.deviceCountChange = ^{
            [weakself startRefresh];
        };
    }
    return _deviceList;
}


- (MHCCVideoViewController *)videoControl {
    if (!_videoControl) {
        _videoControl = [[MHCCVideoViewController alloc] initWithCamera:self.camera];
    }
    return _videoControl;
}

- (void)redrawNavigationBar {
    
    UIImage* leftImage = [[UIImage imageNamed:@"navi_back_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if(!_tabView.currentIndex || _tabView.currentIndex == 1) {
        leftImage = [[UIImage imageNamed:@"navi_back_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        UIImage* imageMore = [[UIImage imageNamed:@"navi_more_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        if(self.camera.shareFlag == MHDeviceUnShared){
            UIBarButtonItem *rightItemMore = [[UIBarButtonItem alloc] initWithImage:imageMore
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(onMore:)];
            self.navigationItem.rightBarButtonItem = rightItemMore;
        }
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.navigationItem.rightBarButtonItem = nil;
    }
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:leftImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - more btn
// 点击设备页面右上角(...)按钮后的响应函数
- (void)onMore:(id)sender {
    //。。。更多按钮，actionsheet
    XM_WS(weakself);
    
    //    if (_animationTool.currentIndex == 1) {
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    
    NSMutableArray *objects = [NSMutableArray new];
    
    [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.tutorial",@"plugin_gateway","新手引導") isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        NSString *strURL = kNewUserCN;
        [weakself openWebVC:strURL identifier:@"mydevice.gateway.about.tutorial" share:NO];
        [weakself gw_clickMethodCountWithStatType:@"ACPartnerTutorial"];
    }]];
    
    [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objects];
    
    //    }
    //    else {
    
    //
    //        NSString* strSetting = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    //        //    NSString* strNew = NSLocalizedStringFromTable(@"mydevice.gateway.about.tutorial",@"plugin_gateway","新手引導");
    //        NSString* strNew = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.more.newir",@"plugin_gateway","重新匹配空调");
    //        NSString *strTimer = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
    //        //    NSString* strAbout = NSLocalizedStringFromTable(@"mydevice.gateway.about.titlesettingcell",@"plugin_gateway","关于");
    //        NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    //        NSString* strShare = NSLocalizedStringFromTable(@"mydevice.actionsheet.share",@"plugin_gateway","设备共享");
    //        NSString* strUpgrade = NSLocalizedStringFromTable(@"mydevice.actionsheet.upgrade",@"plugin_gateway","检查固件升级");
    //        NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    //        NSString* strLife = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.actionsheet.life",@"plugin_gateway","生活场景");
    //
    //        NSArray *titlesArray = @[ strTimer, strNew, strSetting, strChangeTitle, strShare, strUpgrade, strFeedback, strLife ];
    //
    //        [[MHPromptKit shareInstance] showPromptInView:self.view withHandler:^(NSInteger buttonIndex) {
    //            switch (buttonIndex) {
    //                case 0: {
    //                    //取消
    //                    break;
    //                }
    //                case 8: {
    //                    [weakself openWebVC:kAC_SCENE_URL identifier:@"mydevice.gateway.sensor.acpartner.actionsheet.life" share:NO];
    //                    [weakself gw_clickMethodCountWithStatType:@"openACPartnerLifeScene"];
    //                    break;
    //                }
    //                case 1: {
    //                    MHACPartnerTimerNewSettingViewController *tVC = [[MHACPartnerTimerNewSettingViewController alloc] initWithDevice:weakself.acPartner andIdentifier:kACPARTNERTIMERID];
    //                    tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
    //                    tVC.controllerIdentifier = kACPARTNERTIMERID;
    //                    [weakself.navigationController pushViewController:tVC animated:YES];
    //                    [weakself gw_clickMethodCountWithStatType:@"openACPartnerTimerSetting"];
    //                    break;
    //                }
    //                case 2: {
    //                    MHACPartnerReMatchViewController *rematchVC = [[MHACPartnerReMatchViewController alloc] initWithAcpartner:weakself.acPartner type:REMACTCH_INDEX];
    //                    [weakself.navigationController pushViewController:rematchVC animated:YES];
    //
    //                    [weakself gw_clickMethodCountWithStatType:@"openACPartnerRemactchPage"];
    //
    //                    break;
    //                }
    //                case 3: {
    //                    MHFeedbackDeviceDetailViewController *detailVC = [MHFeedbackDeviceDetailViewController new];
    //                    detailVC.category = Device;
    //                    detailVC.device = weakself.acPartner;
    //                    [weakself.navigationController pushViewController:detailVC animated:YES];
    //                    [weakself gw_clickMethodCountWithStatType:@"openACPartnerFreFAQ"];
    //                    break;
    //                }
    //                case 4: {
    //                    [self gw_clickMethodCountWithStatType:@"openACPartnerChangeName"];
    //                    [self deviceChangeName];
    //                    break;
    //                }
    //                case 5: {
    //                    [self gw_clickMethodCountWithStatType:@"openACPartnerShare"];
    //                    [self deviceShare];
    //                    break;
    //                }
    //                case 6: {
    //                    [self gw_clickMethodCountWithStatType:@"openACPartnerUpgradePage"];
    //                    [self onDeviceUpgradePage];
    //                    break;
    //                }
    //                case 7: {
    //                    //反馈
    //                    [self gw_clickMethodCountWithStatType:@"openACPartnerFeedback"];
    //                    [weakself onFeedback];
    //                    break;
    //                }
    //                default:
    //                    break;
    //            }
    //        } withTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多") cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") destructiveButtonTitle:nil otherButtonTitlesArray:titlesArray];
    //    }
    
}

- (void)openWebVC:(NSString *)strURL identifier:(NSString *)identifier share:(BOOL)share{
    MHGatewayWebViewController *web = [MHGatewayWebViewController openWebVC:strURL identifier:identifier share:share];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)startRefresh {
    [self.controlView startRefresh];
}
#pragma mark : - check version
- (void)checkVersion {
    XM_WS(weakself);
    [self.camera versionControl:^(NSInteger retcode) {
        [weakself onDeviceUpgradePage];  
    }];
}

#pragma mark - loadstatus
- (void)loadStatus {
//    XM_WS(weakself);
    //    [self startRefresh];
    //    NSDictionary *params = [self.camera getStatusRequestPayload];
    //    [self.camera sendPayload:params success:nil failure:nil];
    //    [self.camera getProperty:ARMING_DELAY_INDEX success:nil failure:nil];
}
#pragma mark :- 其它状态
- (void)getOtherStatus {
    XM_WS(weakself);
    __block MHSafeDictionary *tempDic = [[MHSafeDictionary alloc] init];
    [self.camera.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL *stop) {
        sensor.parent = weakself.camera;
        NSString *name = sensor.name;
        [tempDic setObject:name forKey:sensor.did];
    }];
    //网关时间可能did是网关的did导致取不到子设备名字
    [tempDic setObject:@"小米多功能网关" forKey:self.camera.did];
    self.camera.logManager.deviceNames = tempDic;
    
    
//    [[MHGatewayBindSceneManager sharedInstance] fetchBindSceneList:self.camera withSuccess:nil];
    [[MHGatewayExtraSceneManager sharedInstance] fetchExtraMapTableWithSuccess:nil failure:nil];
//
}

#pragma mark - MHLumiTUTKClientDelegate
- (void)client:(MHLumiTUTKClient *)client onVideoReceived:(AVFrame*)frame
avcodecContext:(AVCodecContext*)avcodecContext
 gotPicturePtr:(int)gotPicturePtr{
    MHVideoFrameYUV* yuvFrame = [[MHVideoFrameYUV alloc] initWithFrame: frame
                                                              withSize:CGSizeMake(avcodecContext->width, avcodecContext->height)];
    if (yuvFrame.size.width > 0 && yuvFrame.size.height > 0)
    {
        NSLog(@"更新画面");
        [self.eaglView setDataSize:(int)yuvFrame.size.width andHeight:(int)yuvFrame.size.height];
    }
    XM_WS(weakself);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.eaglView drawVideoFrame:yuvFrame];
        CGFloat w = [[UIScreen mainScreen] bounds].size.width;
        CGFloat h = w/(yuvFrame.size.width)*(yuvFrame.size.height);
        CGRect rect = CGRectMake(0, 64, w, h);
        weakself.eaglView.frame = rect;
    });
}

- (void)client:(MHLumiTUTKClient *)client onAudioReceived:(void *)audiobuffer length:(int)length{
    if (!self.lumiNeAACDecoder){
        self.lumiNeAACDecoder = [[MHLumiNeAACDecoder alloc] initWithaudioData:audiobuffer length:length samplerate:44100 channelNum:2];
    }
    
    void *audioOutBuffe1r = [self.lumiNeAACDecoder decodeAudioData:audiobuffer length:length];
    unsigned long dataLength = [self.lumiNeAACDecoder dataLengthWithFormatId];
    if (dataLength > 0){
        NSLog(@"IIIIIIIIIIIIIIIII");
        NSData *audioData = [[NSData alloc] initWithBytes:audioOutBuffe1r length:dataLength];
        [self.audioPlayer addAudioBuffer:audioData];
    }
}
#pragma mark - 声音切换
- (void)audioButtonAction:(UIButton*)sender{
    __weak typeof(self) weakself = self;
    NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId];
    if(_isAudioPlay){
        [self.lumiTUTKClient stopAudioStreamWithJsonString:jsonStr completedHandler:^(MHLumiTUTKClient *client , int retcode) {
            if (retcode >= 0 || retcode == AV_ER_NOT_INITIALIZED || retcode == kIsNotFetchingVideoData){
                [[MHTipsView shareInstance] showTipsInfo:@"关闭声音成功" duration:2 modal:NO];
                [weakself stopAudioPlay];
            }else{
                [[MHTipsView shareInstance] showTipsInfo:@"声音关闭失败" duration:2 modal:NO];
            }
        }];
        return;
    }
    [self prepareAudio];
    [self.lumiTUTKClient startAudioStreamWithJsonString:jsonStr startRequestData:YES completedHandler:^(MHLumiTUTKClient *client, int retCode) {
        if (retCode >= 0){
            [weakself startAudioPlay];
            [[MHTipsView shareInstance] showTipsInfo:@"开启声音成功" duration:1 modal:YES];
            
        }else{
            [[MHTipsView shareInstance] showTipsInfo:@"开启声音失败" duration:1 modal:YES];
            [weakself stopAudioPlay];
        }
    }];
}

- (void)prepareAudio{
    NSError *error = nil;
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (_audioPlayer == nil) {
        _audioPlayer = [PlayAudio shareInstance];
    }
    [_audioPlayer reset];
}

-(void)startAudioPlay{
    if (!_isAudioPlay) {
        _isAudioPlay = YES;
        [_audioPlayer startPlay];
    }
}

-(void)stopAudioPlay{
    if (_isAudioPlay) {
        _isAudioPlay = NO;
        [_audioPlayer stopPlay];
    }
}

@end
