//
//  MHLumiFMTabViewController.m
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMTabViewController.h"
#import "MHGatewayTabView.h"
#import "MHLumiFMRadioViewController.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHLumiXMDataManager.h"
#import "MHLumiFmPlayerViewController.h"
#import "MHLumiFMSearchViewController.h"

@interface MHLumiFMTabViewController ()

@property (nonatomic,strong) MHLumiFMRadioViewController *rankRadio;
@property (nonatomic,strong) MHLumiFMRadioViewController *localRadio;
@property (nonatomic,strong) MHLumiFMRadioViewController *countryRadio;
@property (nonatomic,strong) MHLumiFMRadioViewController *networkRadio;
@property (nonatomic,strong) MKPlacemark *currentPlaceMark;
@property (nonatomic,assign) CGRect tableFrame;
@property (nonatomic,strong) MHGatewayTabView *tabView;

@end

@implementation MHLumiFMTabViewController
{
    MHDeviceGateway *           _radioDevice;
}

- (id)initWithRadio:(MHDeviceGateway *)radio {
    self = [super init];
    if (self) {
        _radioDevice = radio;
    }
    return self;
}

- (void)setTableFrame:(CGRect)tableFrame {
    if(_tableFrame.size.height != tableFrame.size.height){
        _tableFrame = tableFrame;
        self.rankRadio.viewFrame = tableFrame;
        self.localRadio.viewFrame = tableFrame;
        self.countryRadio.viewFrame = tableFrame;
        self.networkRadio.viewFrame = tableFrame;
    }
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.addcollectionlist", @"plugin_gateway", nil);

    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [swipeRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeRight];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [swipeLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:swipeLeft];
    
//    [[MHLumiXMDataManager sharedInstance] fetchXMHotWordsWithCompletionHandler:nil];
    
    UIImage* imageMore = [[UIImage imageNamed:@"lumi_fm_radio_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItemMore = [[UIBarButtonItem alloc] initWithImage:imageMore style:UIBarButtonItemStylePlain target:self action:@selector(onSearch:)];
    self.navigationItem.rightBarButtonItem = rightItemMore;
}

- (void)onSearch:(id)sender {
    MHLumiFMSearchViewController *search = [[MHLumiFMSearchViewController alloc] init];
    search.isTabBarHidden = YES;
    search.radioDevice = _radioDevice;
    search.fmPlayer = _fmPlayer;
    _fmPlayer.hidden = YES;
    [self.navigationController pushViewController:search animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.fmPlayer = [MHLumiFmPlayer shareInstance];
    [self fmCallback];
    
    [_rankRadio.tvcInternal stopRefreshAndReload];
    [_localRadio.tvcInternal stopRefreshAndReload];
    [_countryRadio.tvcInternal stopRefreshAndReload];
    [_networkRadio.tvcInternal stopRefreshAndReload];
}

- (void)buildSubviews {
    [super buildSubviews];
    XM_WS(weakself);
    _currentPlaceMark = [[MHLocationManager sharedInstance] currentPlaceMark];
    
    if (_fmPlayer.isHide){
        self.tableFrame = CGRectMake(0,122, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-122);
    }
    else {
        self.tableFrame = CGRectMake(0,122, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-122-MiniPlayerHeight);
    }
    _rankRadio = [[MHLumiFMRadioViewController alloc] initWithFrame:self.tableFrame andRadioDevice:_radioDevice];
    _rankRadio.view.hidden = YES;
    _rankRadio.fmPlayer = _fmPlayer;
    _rankRadio.radioSelected = ^(MHLumiXMRadio *radio){
        [weakself playRadioWith:radio];
    };
    [self.view addSubview:_rankRadio.view];
    
    _localRadio = [[MHLumiFMRadioViewController alloc] initWithFrame:self.tableFrame andRadioDevice:_radioDevice];
    _localRadio.view.hidden = YES;
    _localRadio.fmPlayer = _fmPlayer;
    _localRadio.radioSelected = ^(MHLumiXMRadio *radio){
        [weakself playRadioWith:radio];
    };
    [self.view addSubview:_localRadio.view];
    
    _countryRadio = [[MHLumiFMRadioViewController alloc] initWithFrame:self.tableFrame andRadioDevice:_radioDevice];
    _countryRadio.view.hidden = YES;
    _networkRadio.fmPlayer = _fmPlayer;
    _countryRadio.radioSelected = ^(MHLumiXMRadio *radio){
        [weakself playRadioWith:radio];
    };
    [self.view addSubview:_countryRadio.view];
    
    _networkRadio = [[MHLumiFMRadioViewController alloc] initWithFrame:self.tableFrame andRadioDevice:_radioDevice];
    _networkRadio.view.hidden = YES;
    _networkRadio.fmPlayer = _fmPlayer;
    _networkRadio.radioSelected = ^(MHLumiXMRadio *radio){
        [weakself playRadioWith:radio];
    };
    [self.view addSubview:_networkRadio.view];

    //Tab view
    NSArray *tabTitleArray = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.tab.rank",@"plugin_gateway","排行"), NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.tab.local",@"plugin_gateway","本地"), NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.tab.country",@"plugin_gateway","国家"),
                              NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.tab.network",@"plugin_gateway","网络"), nil];
    CGRect tabRect = CGRectMake(20, 76, CGRectGetWidth(self.view.bounds) - 40, 34);
    _tabView = [[MHGatewayTabView alloc] initWithFrame:tabRect
                                            titleArray:tabTitleArray
                                             stypeType:LumiTabStyleWithFrame
                                              callback:^(NSInteger idx) {
        [weakself onTabClicked:idx];
    }];
    [self.view addSubview:_tabView];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 121, CGRectGetWidth(self.view.bounds) - 40, 1)];
    line.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.view addSubview:line];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tab change
- (void)onTabClicked:(NSInteger)index {
    XM_WS(weakself);
    switch (index) {
        case 0:
            _rankRadio.view.hidden = NO;
            _localRadio.view.hidden = YES;
            _networkRadio.view.hidden = YES;
            _countryRadio.view.hidden = YES;
            _rankRadio.radioType = Radio_Rank;
            break;
        case 1:
        {
            _rankRadio.view.hidden = YES;
            _localRadio.view.hidden = NO;
            _networkRadio.view.hidden = YES;
            _countryRadio.view.hidden = YES;
            _localRadio.currentPlace = _currentPlaceMark;
            _localRadio.radioType = Radio_Province;
            
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating", @"plugin_gateway", nil) modal:YES];
            [[MHLumiXMDataManager sharedInstance] restoreProvinceDataIfNotLaunchRequestWithdCompleteHandle:^(id obj, bool flag) {
                if (flag){
                    [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"done", @"plugin_gateway", nil) duration:1 modal:YES];
                }else{
                    [[MHTipsView shareInstance] hide];
                }
                [[MHLocationManager sharedInstance] requestCurrentLocationAndPlaceMarkWithSuccess:^(MKPlacemark *place){
                    NSLog(@"-=-=-=--=-=-=-=-%@",place.description);
                    weakself.currentPlaceMark = place;
                    weakself.localRadio.currentPlace = place;
                    weakself.localRadio.radioType = Radio_Province;
                    
                } fail:^(NSInteger errorCode){
                    if(errorCode == ErrorCodeOfLBSUserDeny){
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.location.fail", @"plugin_gateway", nil) duration:1.5f modal:YES];
                    }
                }];
            }];
        }
            break;
        case 2:
            _rankRadio.view.hidden = YES;
            _localRadio.view.hidden = YES;
            _networkRadio.view.hidden = YES;
            _countryRadio.view.hidden = NO;
            _countryRadio.radioType = Radio_Country;
            break;
        case 3:
            _rankRadio.view.hidden = YES;
            _localRadio.view.hidden = YES;
            _countryRadio.view.hidden = YES;
            _networkRadio.view.hidden = NO;
            _networkRadio.radioType = Radio_NetWork;
            break;
        default:
            break;
    }
}

- (void)animateViewChange:(UISwipeGestureRecognizerDirection)direction withIndex:(NSInteger)index {
    CATransition *animation = [[CATransition alloc] init];
    animation.duration = 0.5;
    animation.timingFunction = [ CAMediaTimingFunction  functionWithName: kCAMediaTimingFunctionEaseInEaseOut ];
    animation.type = kCATransitionPush;

    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        animation.subtype = kCATransitionFromRight;
        if (index == 1) {
            [_rankRadio.view.layer addAnimation:animation forKey:nil];
            [_localRadio.view.layer addAnimation:animation forKey:nil];
        }
        else if (index == 2) {
            [_localRadio.view.layer addAnimation:animation forKey:nil];
            [_countryRadio.view.layer addAnimation:animation forKey:nil];
        }
        else if (index == 3){
            [_countryRadio.view.layer addAnimation:animation forKey:nil];
            [_networkRadio.view.layer addAnimation:animation forKey:nil];
        }
    }
    else if (direction == UISwipeGestureRecognizerDirectionRight){
        animation.subtype = kCATransitionFromLeft;
        if (index == 0) {
            [_rankRadio.view.layer addAnimation:animation forKey:nil];
            [_localRadio.view.layer addAnimation:animation forKey:nil];
        }
        else if (index == 1) {
            [_localRadio.view.layer addAnimation:animation forKey:nil];
            [_countryRadio.view.layer addAnimation:animation forKey:nil];
        }
        else if (index == 2){
            [_countryRadio.view.layer addAnimation:animation forKey:nil];
            [_networkRadio.view.layer addAnimation:animation forKey:nil];
        }
    }
}

-(void)swiped:(UISwipeGestureRecognizer *)sender{
    NSInteger total = _tabView.titleArray.count;
    NSInteger current = _tabView.currentIndex;
    NSInteger next = 0;
    
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        next = current + 1;
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
        next = current - 1;
    }
    
    if (next < total && next >= 0){
        [self animateViewChange:sender.direction withIndex:next];
        [_tabView selectItem:next];
    }
}

#pragma mark - radio control
- (void)playRadioWith:(MHLumiXMRadio *)radio {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];

    [_radioDevice playSpecifyRadioWithProgramID:[[radio valueForKey:@"radioId"] integerValue]
                                            Url:[radio valueForKey:@"radioRateUrl"]
                                           Type:@"0"
                                     andSuccess:^(id obj){
                                         [[MHTipsView shareInstance] hide];
                                         [weakself showFmPlayer:radio];

                                     } andFailure:^(NSError *error){
                                         [[MHTipsView shareInstance] hide];
                                         NSLog(@"%@",error);
                                     }];
}

- (void)showFmPlayer:(id)radio {
    self.tableFrame = CGRectMake(0, 122,
                                 CGRectGetWidth(self.view.bounds),
                                 CGRectGetHeight(self.view.bounds) - 122 - MiniPlayerHeight);

    if(self.fmPlayer.isHide){
        self.fmPlayer = [MHLumiFmPlayer shareInstance];
        [self.fmPlayer showMiniPlayer:CGRectGetMaxY(self.view.bounds) - MiniPlayerHeight isMainPage:NO];
    }
    
    if(self.tabView.currentIndex == 0){
        self.fmPlayer.radioPlayList = self.rankRadio.dataSource;
    }
    else if(self.tabView.currentIndex == 1){
        self.fmPlayer.radioPlayList = self.localRadio.dataSource;
    }
    else if(self.tabView.currentIndex == 2){
        self.fmPlayer.radioPlayList = self.countryRadio.dataSource;
    }
    else if(self.tabView.currentIndex == 3){
        self.fmPlayer.radioPlayList = self.networkRadio.dataSource;
    }
    self.fmPlayer.isPlaying = YES;
    self.fmPlayer.currentRadio = radio;
    
    [self fmCallback];
}

- (void)fmCallback {
    XM_WS(weakself);
    self.fmPlayer.playCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself hideAllCellAnimation];
        [weakself showAnimation:currentRadio];
        
        weakself.networkRadio.fmPlayer = weakself.fmPlayer;
        weakself.localRadio.fmPlayer = weakself.fmPlayer;
        weakself.rankRadio.fmPlayer = weakself.fmPlayer;
        weakself.countryRadio.fmPlayer = weakself.fmPlayer;
    };
    
    self.fmPlayer.pauseCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself hideAllCellAnimation];
    };
    
    self.fmPlayer.showFullPlayerCallBack = ^() {
        [weakself showFullPlayer];
    };
}

- (void)hideAllCellAnimation {
    if(self.tabView.currentIndex == 0){
        [self.rankRadio hideAllCellAnimation];
    }
    else if(self.tabView.currentIndex == 1){
        [self.localRadio hideAllCellAnimation];
    }
    else if(self.tabView.currentIndex == 2){
        [self.countryRadio hideAllCellAnimation];
    }
    else if(self.tabView.currentIndex == 3){
        [self.networkRadio hideAllCellAnimation];
    }
}

- (void)showAnimation:(MHLumiXMRadio *)currentRadio {
    if(self.tabView.currentIndex == 0){
        [self.rankRadio showAnimation:currentRadio];
    }
    else if(self.tabView.currentIndex == 1){
        [self.localRadio showAnimation:currentRadio];
    }
    else if(self.tabView.currentIndex == 2){
        [self.countryRadio showAnimation:currentRadio];
    }
    else if(self.tabView.currentIndex == 3){
        [self.networkRadio showAnimation:currentRadio];
    }
}

- (void)showFullPlayer {
    MHLumiFmPlayerViewController *fullPlayer = [[MHLumiFmPlayerViewController alloc] init];
    fullPlayer.miniPlayer = [MHLumiFmPlayer shareInstance];
    
    XM_WS(weakself);
    [self presentViewController:fullPlayer animated:YES completion:^{
        weakself.fmPlayer.hidden = YES;
    }];
}

@end
