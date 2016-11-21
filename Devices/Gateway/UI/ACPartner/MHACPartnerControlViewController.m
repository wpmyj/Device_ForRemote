//
//  MHACPartnerControlViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerControlViewController.h"
#import "MHACPartnerControlHeaderView.h"
#import "MHACPartnerControlPanel.h"
#import "MHACPartnerInfoView.h"
#import "MHGatewayNetworkStatusView.h"
#import "MHLumiFMCollectViewController.h"
#import "MHACPartnerDetailViewController.h"
#import "MHACPartnerAddTipsViewController.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLuDeviceViewControllerBase.h"
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHGatewayLogViewController.h"


@interface MHACPartnerControlViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) MHDeviceAcpartner *acpartner;

@property (nonatomic,assign) CGFloat canvasHeight;


@property (nonatomic,strong) UIView *headerViewBuffer;

@property (nonatomic,strong) UIScrollView *verticalCanvas;

@property (nonatomic,strong) MHACPartnerControlHeaderView  *headerView;
@property (nonatomic,strong) MHACPartnerControlPanel *controlPanel;
@property (nonatomic,strong) MHACPartnerInfoView *infoView;
@property (nonatomic,strong) NSMutableArray *controlSubDevices;
@property (nonatomic,strong) NSMutableArray *subInfoDevices;

@property (nonatomic ,strong) UIView *whiteView;
@property (nonatomic ,strong) UILabel *tipsText;
@end

@implementation MHACPartnerControlViewController
{
    NSTimer*                _powerTimer;

    
    NSInteger                               _headerViewLastIndex;
    
    MHGatewayNetworkStatusView *            _networkStatusView;
}

- (id)initWithFrame:(CGRect)frame acpartner:(MHDeviceAcpartner *)acpartner {
    if (self = [super init]) {
        self.acpartner = acpartner;
        self.isTabBarHidden = YES;
        self.view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
        self.view.frame = frame;
    }
    return self;
}


- (void)dealloc {
  
}

- (void)viewDidLoad {
    NSString *key = [NSString stringWithFormat:@"%@%@",ACHeaderViewLastIndexKey,self.acpartner.did];
    _headerViewLastIndex = [[[NSUserDefaults standardUserDefaults] valueForKey:key] integerValue];
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    XM_WS(weakself);
    self.isNavBarTranslucent = YES;

    [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingReachabilityDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        if ([MHReachability sharedManager].networkReachabilityStatus <= 0) {
            //网络不通，显示
            weakself.verticalCanvas.frame = CGRectMake(0, 104, WIN_WIDTH, WIN_HEIGHT - 104);
            [weakself networkStatus:YES];
        } else {
            //网络通畅，隐藏
            weakself.verticalCanvas.frame = CGRectMake(0, 64, WIN_WIDTH, WIN_HEIGHT - 64);
            [weakself networkStatus:NO];
        }
    }];
    
    if ([MHReachability sharedManager].networkReachabilityStatus <= 0) {
        //网络不通，显示
        weakself.verticalCanvas.frame = CGRectMake(0, 104, WIN_WIDTH, WIN_HEIGHT - 104);
        [weakself networkStatus:YES];
    } else {
        //网络通畅，隐藏
        weakself.verticalCanvas.frame = CGRectMake(0, 64, WIN_WIDTH, WIN_HEIGHT - 64);
        [weakself networkStatus:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//     _powerTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(startGetQuant) userInfo:nil repeats:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if(_controlPanel && !_controlPanel.shouldKeepRunning) [_controlPanel startWatchingDeviceStatus];
    //        if(_infoView && !_infoView.shouldKeepRunning) [_infoView startWatchingLatestLog];
    
    [_infoView.tableView reloadData];
    //刷新控件状态
    [_headerView updateMainPageStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.controlPanel stopWatchingDeviceStatus];
}


- (void)networkStatus:(BOOL)show {
    if(show) {
        [_networkStatusView removeFromSuperview];
        _networkStatusView = nil;
        _networkStatusView = [[MHGatewayNetworkStatusView alloc] initWithFrame:CGRectMake(0, 64, WIN_WIDTH, 40)];
        [self.view addSubview:_networkStatusView];
    }
    else {
        [_networkStatusView removeFromSuperview];
        _networkStatusView = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if(_controlPanel) [_controlPanel stopWatchingDeviceStatus];
    //    if(_infoView) [_infoView stopWatchingLatestLog];
//    
    NSString *key = [NSString stringWithFormat:@"%@%@",ACHeaderViewLastIndexKey,self.acpartner.did];
    [[NSUserDefaults standardUserDefaults] setObject:@(_headerView.currentPageIndex) forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];

}


- (void)setCanvasHeight:(CGFloat)canvasHeight {
    _canvasHeight = canvasHeight;
    [_verticalCanvas setContentSize:CGSizeMake(WIN_WIDTH, canvasHeight)];
}

- (void)buildSubviews {
    [super buildSubviews];
    XM_WS(weakself);
    _headerViewBuffer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 64 + WIN_HEIGHT * 0.4)];
    [self.view addSubview:_headerViewBuffer];
    
    _verticalCanvas = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, WIN_WIDTH, WIN_HEIGHT - 64)];
    
    _verticalCanvas.delegate = self;
    [self.view addSubview:_verticalCanvas];
    
    CGRect headerFrame = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT * 0.4);
    _headerView = [[MHACPartnerControlHeaderView alloc] initWithFrame:headerFrame sensor:self.acpartner];
    
    _headerView.clickCallBack = ^(DetailType type){
       
        UIViewController *destinationVC = nil;
        
        switch (type) {
            case Acpartner_MainPage_AddAC: {
               destinationVC = [[MHACPartnerAddTipsViewController alloc] initWithAcpartner:weakself.acpartner];
            }
                break;
            case Acpartner_MainPage_ACDetail: {
                destinationVC = [[MHACPartnerDetailViewController alloc] initWithAcpartner:weakself.acpartner];

            }
                break;
            case Acpartner_MainPage_FM: {
                [weakself gw_clickMethodCountWithStatType:@"openFMCollectionPage"];
                destinationVC = [[MHLumiFMCollectViewController alloc] initWithRadioDevice:weakself.acpartner];
            }
                break;

            default:
                break;
        }
        [weakself.navigationController pushViewController:destinationVC animated:YES];

//        if (weakself.navigationClick) {
//            weakself.navigationClick(destinationVC);
//        }
    };

    [_headerView updateMainPageStatus];
    _headerView.headerBufferView = _headerViewBuffer;
    [_verticalCanvas addSubview:_headerView];
    _headerView.currentPageIndex = _headerViewLastIndex;
    
    [self buildSubDevices];
    
    if(_controlSubDevices.count){
        CGRect controlFrame = CGRectMake(0, CGRectGetMaxY(_headerView.frame), WIN_WIDTH, 110);
        _controlPanel = [[MHACPartnerControlPanel alloc] initWithFrame:controlFrame sensor:self.acpartner subDevices:_controlSubDevices];
        [_verticalCanvas addSubview:_controlPanel];
        [self rebuildHeight:CGRectGetHeight(_controlPanel.frame) currentFrame:controlFrame];
        if(!_controlPanel.shouldKeepRunning) [_controlPanel startWatchingDeviceStatus];
        _controlPanel.chooseServiceIcon = ^(MHDeviceGatewayBaseService *service){
            [weakself openServiceIconPage:service];
//            if(weakself.chooseServiceIcon) weakself.chooseServiceIcon(service);
        };
        _controlPanel.openDevicePageCallback = ^(MHDeviceGatewayBaseService *service){
            __block MHDeviceGatewayBase *openedSensor = nil;
            [weakself.controlSubDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL *stop) {
                if([service.serviceParentDid isEqualToString:sensor.did]){
                    openedSensor = sensor;
                }
            }];
            if(openedSensor){
                [weakself opendeviePage:openedSensor];
//                if (weakself.openDevicePageCallback)weakself.openDevicePageCallback(openedSensor);
            }
        };
    }
    
    if(_subInfoDevices.count){
        CGRect infoFrame = CGRectMake(0, CGRectGetMaxY(_controlPanel.frame), WIN_WIDTH, 90);
        if(!_controlSubDevices.count) infoFrame = CGRectMake(0, CGRectGetMaxY(_headerView.frame), WIN_WIDTH, 90);
        _infoView = [[MHACPartnerInfoView alloc] initWithFrame:infoFrame
                                                      sensor:self.acpartner
                                                  subDevices:_subInfoDevices
                                              callbackHeight:^(CGFloat height) {
                                                  [weakself rebuildHeight:height currentFrame:infoFrame];
                                              }];
        _infoView.openDevicePageCallback = ^(MHDeviceGatewayBase *sensor) {
            [weakself opendeviePage:sensor];
//            if(weakself.openDevicePageCallback)weakself.openDevicePageCallback(sensor);
        };
        _infoView.openDeviceLogPageCallback = ^(MHDeviceGatewayBase *sensor){
            [weakself openDeviceLogPage:sensor];
//            if(weakself.openDeviceLogPageCallback)weakself.openDeviceLogPageCallback(sensor);
        };
        _infoView.chooseServiceIcon = ^(MHDeviceGatewayBaseService *service){
            [weakself openServiceIconPage:service];
           //            if(weakself.chooseServiceIcon) weakself.chooseServiceIcon(service);
        };
        //        if(!_infoView.shouldKeepRunning) [_infoView startWatchingLatestLog];
        [_verticalCanvas addSubview:_infoView];
    }
        if (!_subInfoDevices.count && !_controlSubDevices.count) {
            _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + WIN_HEIGHT * 0.5, WIN_WIDTH, 130)];
            [self.view addSubview:_whiteView];
            _tipsText = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, WIN_WIDTH - 40, 90)];
            _tipsText.font = [UIFont systemFontOfSize:15.0f];
            _tipsText.textColor = [MHColorUtils colorWithRGB:0x606060];
            _tipsText.numberOfLines = 0;
            _tipsText.lineBreakMode = NSLineBreakByWordWrapping;
            NSString *tips =  NSLocalizedStringFromTable(@"mydevice.gateway.mainPage.nodevice.tips",@"plugin_gateway","当前没有子设备");
            NSString *device = NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title3",@"plugin_gateway","设备");
            NSMutableAttributedString *tipsAttribute = [[NSMutableAttributedString alloc] initWithString:tips];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:5];//调整行间距
    
            [tipsAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [tips length])];
            [tipsAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[tips rangeOfString:device options:NSBackwardsSearch]];
            _tipsText.attributedText = tipsAttribute;
            _tipsText.textAlignment = NSTextAlignmentCenter;
            [self.whiteView addSubview:_tipsText];
        }
    
//    UIView *navBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 64)];
//    navBack.backgroundColor = [MHColorUtils colorWithRGB:0x22333f];
//    [self.view addSubview:navBack];

}

- (void)rebuildHeight:(CGFloat)height currentFrame:(CGRect)currentFrame {
    CGSize size = CGSizeMake(WIN_WIDTH, CGRectGetMaxY(currentFrame) + height);
    [_verticalCanvas setContentSize:size];
        if (_subInfoDevices.count || _controlSubDevices.count) {
            [self.whiteView removeFromSuperview];
        }
}

- (void)buildSubDevices {
    _subInfoDevices = [NSMutableArray arrayWithArray:self.acpartner.subDevices];
    _controlSubDevices = [NSMutableArray arrayWithCapacity:1];
    
    for(MHDeviceGatewayBase *sensor in self.acpartner.subDevices){
        NSString *className = NSStringFromClass([sensor class]);
        if([className isEqualToString:@"MHDeviceGatewaySensorPlug"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorSingleNeutral"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorDoubleNeutral"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorCurtain"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorCassette"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorXBulb"] ){
            [_controlSubDevices addObject:sensor];
            [_subInfoDevices removeObject:sensor];
        }
    }
}

#pragma mark - scroll view delegate 根据scrollview滑动调整headerview遮罩的高度
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0) {
        _headerViewBuffer.frame = CGRectMake(0, 0, WIN_WIDTH, 64 + WIN_HEIGHT * 0.6 - offsetY);
    }
    else if(offsetY > 0) {
        _headerViewBuffer.frame = CGRectMake(0, 0, WIN_WIDTH, 64 + WIN_HEIGHT * 0.6 - offsetY);
        if(WIN_HEIGHT * 0.5 - offsetY < 0 )
            _headerViewBuffer.frame = CGRectMake(0, 0, WIN_WIDTH, 64);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _headerViewBuffer.frame = CGRectMake(0, 0, WIN_WIDTH, 64 + WIN_HEIGHT * 0.4);
}



#pragma mark - 功率
- (void)startGetQuant {
    XM_WS(weakself);
    [self.acpartner getACDeviceProp:AC_POWER_ID success:^(id respObj) {
        weakself.acpartner.ac_power = [respObj[0] floatValue];
        [self.headerView updateMainPageStatus];
    } failure:^(NSError *error) {
        
    }];
}

- (void)stopGetQuant {
    if(_powerTimer){
        [_powerTimer invalidate];
        _powerTimer = nil;
    }
}

- (void)startRefresh {
    [self.headerView updateMainPageStatus];
    if ((self.subInfoDevices.count + self.controlSubDevices.count) == self.acpartner.subDevices.count) {
            return;
        }
        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview removeFromSuperview];
        }];
    [self buildSubviews];

}

- (void)stopRefresh {
    
    [self.controlPanel stopWatchingDeviceStatus];

}
#pragma mark - 打开设备页
- (void)openDeviceLogPage:(MHDeviceGatewayBase *)sensor {
    if([sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorHumiture")]) {
        [self opendeviePage:sensor];
    }
    else {
        MHGatewayLogViewController *log = [[MHGatewayLogViewController alloc] initWithDevice:sensor];
        log.isTabBarHidden = YES;
        log.title = [NSString stringWithFormat:@"%@%@",sensor.name, NSLocalizedStringFromTable(@"mydevice.gateway.log",@"plugin_gateway", "")];
        [self.navigationController pushViewController:log animated:YES];
    }
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openDeviceLogPage_%@", NSStringFromClass([sensor class])]];

}
- (void)opendeviePage:(MHDeviceGatewayBase *)sensor {
    Class deviceClassName = NSClassFromString([[sensor class] getViewControllerClassName]);
    id deviceVC = [[deviceClassName alloc] initWithDevice:sensor];
    [self.navigationController pushViewController:deviceVC animated:YES];
}

- (void)openServiceIconPage:(MHDeviceGatewayBaseService *)service {
    [[MHLumiChooseLogoListManager sharedInstance] chooseLogoWithSevice:service iconID:service.serviceIconId titleIdentifier:service.serviceName segeViewController:self];
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openChooseLogoPage_%@", service.serviceParentClass]];
}


@end
