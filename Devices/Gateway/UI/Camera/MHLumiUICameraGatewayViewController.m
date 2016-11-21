//
//  MHLumiUICameraGatewayViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/10/31.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiUICameraGatewayViewController.h"
#import "MHGatewayControlHeaderView.h"
#import "MHGatewayControlPanel.h"
#import "MHGatewayInfoView.h"
#import "MHLumiFMCollectViewController.h"
#import "MHGatewayNetworkStatusView.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHGatewayLogViewController.h"

/**
 *  主要代码都是从MHGatewayControlViewController复制过来，有时间再重构
 */
@interface MHLumiUICameraGatewayViewController () <UIScrollViewDelegate>

@property (nonatomic,strong) MHDeviceGateway *gateway;
@property (nonatomic,assign) CGFloat canvasHeight;

@property (nonatomic,strong) UIView *headerViewBuffer;

@property (nonatomic,strong) UIScrollView *verticalCanvas;

@property (nonatomic,strong) MHGatewayControlHeaderView  *headerView;
@property (nonatomic,strong) MHGatewayControlPanel *controlPanel;
@property (nonatomic,strong) MHGatewayInfoView *infoView;
@property (nonatomic,strong) NSMutableArray *controlSubDevices;
@property (nonatomic,strong) NSMutableArray *subInfoDevices;

@property (nonatomic ,strong) UIView *whiteView;
@property (nonatomic ,strong) UILabel *tipsText;
@property (nonatomic, strong) NSMutableArray <id<NSObject>> *observers;
@end

@implementation MHLumiUICameraGatewayViewController
{
    
    NSInteger                               _headerViewLastIndex;
    
    MHGatewayNetworkStatusView *            _networkStatusView;
}

- (id)initWithSensor:(MHDeviceGateway* )gateway {
    if (self = [super initWithDevice:gateway]) {
        _gateway = gateway;
        _observers = [NSMutableArray array];
        self.isNavBarTranslucent = YES;
        self.isTabBarHidden = YES;
    }
    return self;
}


- (void)dealloc {
    for (id<NSObject> todoObj in _observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:todoObj];
    }
    [_observers removeAllObjects];
    [_controlPanel stopWatchingDeviceStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
    NSString *key = [NSString stringWithFormat:@"%@%@",HeaderViewLastIndexKey,self.gateway.did];
    _headerViewLastIndex = [[[NSUserDefaults standardUserDefaults] valueForKey:key] integerValue];
    XM_WS(weakself);
    [_observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:@"NightTouchesBegan" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakself.verticalCanvas.scrollEnabled = NO;
        weakself.view.userInteractionEnabled = NO;
        weakself.headerView.mainPageScrollView.scrollEnabled = NO;
        weakself.headerView.userInteractionEnabled = NO;
    }]];
    
    [_observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:@"NightTouchesEnded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakself.verticalCanvas.scrollEnabled = YES;
        weakself.view.userInteractionEnabled = YES;
        weakself.headerView.mainPageScrollView.scrollEnabled = YES;
        weakself.headerView.userInteractionEnabled = YES;
        
    }]];
    
    [_observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:@"NightTouchesCancelled" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakself.verticalCanvas.scrollEnabled = YES;
        weakself.view.userInteractionEnabled = YES;
        weakself.headerView.mainPageScrollView.scrollEnabled = YES;
        weakself.headerView.userInteractionEnabled = YES;
        
    }]];
    
    [_observers addObject:[[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingReachabilityDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        if ([MHReachability sharedManager].networkReachabilityStatus <= 0) {
            //网络不通，显示
            weakself.verticalCanvas.frame = CGRectMake(0, 104, WIN_WIDTH, weakself.view.bounds.size.height - 104);
            [weakself networkStatus:YES];
        } else {
            //网络通畅，隐藏
            weakself.verticalCanvas.frame = CGRectMake(0, 64, WIN_WIDTH, weakself.view.bounds.size.height - 64);
            [weakself networkStatus:NO];
        }
    }]];
    
    if ([MHReachability sharedManager].networkReachabilityStatus <= 0) {
        //网络不通，显示
        self.verticalCanvas.frame = CGRectMake(0, 104, WIN_WIDTH, self.view.bounds.size.height - 104);
        [self networkStatus:YES];
    } else {
        //网络通畅，隐藏
        self.verticalCanvas.frame = CGRectMake(0, 64, WIN_WIDTH, self.view.bounds.size.height - 64);
        [self networkStatus:NO];
    }
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
    
    NSString *key = [NSString stringWithFormat:@"%@%@",HeaderViewLastIndexKey,self.gateway.did];
    [[NSUserDefaults standardUserDefaults] setObject:@(_headerView.currentPageIndex) forKey:key];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_infoView.tableView reloadData];
    //刷新控件状态
    [_headerView updateMainPageStatus];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
    
    _verticalCanvas = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, WIN_WIDTH, self.view.bounds.size.height - 64)];
    _verticalCanvas.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _verticalCanvas.delegate = self;
    [self.view addSubview:_verticalCanvas];
    
    CGRect headerFrame = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT * 0.4);
    _headerView = [[MHGatewayControlHeaderView alloc] initWithFrame:headerFrame sensor:_gateway];
    _headerView.clickCallBack = ^(){
        MHLumiFMCollectViewController *fmPlayerVC = [[MHLumiFMCollectViewController alloc] initWithRadioDevice:weakself.gateway];
        if (weakself.navigationClick) {
            weakself.navigationClick(fmPlayerVC);
        }
    };
    _headerView.headerBufferView = _headerViewBuffer;
    [_verticalCanvas addSubview:_headerView];
    _headerView.currentPageIndex = _headerViewLastIndex;
    
    [self buildSubDevices];
    
    if(_controlSubDevices.count){
        CGRect controlFrame = CGRectMake(0, CGRectGetMaxY(_headerView.frame), WIN_WIDTH, 110);
        _controlPanel = [[MHGatewayControlPanel alloc] initWithFrame:controlFrame sensor:_gateway subDevices:_controlSubDevices];
        [_verticalCanvas addSubview:_controlPanel];
        [self rebuildHeight:CGRectGetHeight(_controlPanel.frame) currentFrame:controlFrame];
        
        _controlPanel.chooseServiceIcon = ^(MHDeviceGatewayBaseService *service){
            [weakself changeLogoWithService:service];
        };
        [_controlPanel startWatchingDeviceStatus];
        
        _controlPanel.openDevicePageCallback = ^(MHDeviceGatewayBaseService *service){
            __block MHDeviceGatewayBase *openedSensor = nil;
            [weakself.controlSubDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL *stop) {
                if([service.serviceParentDid isEqualToString:sensor.did]){
                    openedSensor = sensor;
                    *stop = YES;
                }
            }];
            if(openedSensor){
                [weakself openDeviceLogPage:openedSensor];
                if (weakself.openDevicePageCallback)weakself.openDevicePageCallback(openedSensor);
            }
        };
    }
    
    if(_subInfoDevices.count){
        CGRect infoFrame = CGRectMake(0, CGRectGetMaxY(_controlPanel.frame), WIN_WIDTH, 90);
        if(!_controlSubDevices.count) infoFrame = CGRectMake(0, CGRectGetMaxY(_headerView.frame), WIN_WIDTH, 90);
        _infoView = [[MHGatewayInfoView alloc] initWithFrame:infoFrame
                                                      sensor:_gateway
                                                  subDevices:_subInfoDevices
                                              callbackHeight:^(CGFloat height) {
                                                  [weakself rebuildHeight:height currentFrame:infoFrame];
                                              }];
        _infoView.openDevicePageCallback = ^(MHDeviceGatewayBase *sensor) {
            if(weakself.openDevicePageCallback)weakself.openDevicePageCallback(sensor);
            Class deviceClassName = NSClassFromString([[sensor class] getViewControllerClassName]);
            id deviceVC = [[deviceClassName alloc] initWithDevice:sensor];
            [weakself.navigationController pushViewController:deviceVC animated:YES];
        };
        _infoView.openDeviceLogPageCallback = ^(MHDeviceGatewayBase *sensor){
            if(weakself.openDeviceLogPageCallback)weakself.openDeviceLogPageCallback(sensor);
            [weakself openDeviceLogPage:sensor];
        };
        _infoView.chooseServiceIcon = ^(MHDeviceGatewayBaseService *service){
//            if(weakself.chooseServiceIcon) weakself.chooseServiceIcon(service);
            [weakself changeLogoWithService:service];
        };
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
}

#pragma mark - 打开设备页（长按点击更多）
- (void)openDeviceLogPage:(MHDeviceGatewayBase *)sensor {
    if([sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorHumiture")]) {
        MHGatewayTempAndHumidityViewController *humidity = [[MHGatewayTempAndHumidityViewController alloc] initWithDevice:sensor];
        [humidity graphLogList];
    }
    else {
        MHGatewayLogViewController *log = [[MHGatewayLogViewController alloc] initWithDevice:sensor];
        log.isTabBarHidden = YES;
        log.title = [NSString stringWithFormat:@"%@%@",sensor.name, NSLocalizedStringFromTable(@"mydevice.gateway.log",@"plugin_gateway", "")];
        [self.navigationController pushViewController:log animated:YES];
    }
    
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openDeviceLogPage_%@", NSStringFromClass([sensor class])]];
}

#pragma mark - 修改图标
- (void)changeLogoWithService:(MHDeviceGatewayBaseService *)service{
    [[MHLumiChooseLogoListManager sharedInstance] chooseLogoWithSevice:service iconID:service.serviceIconId titleIdentifier:service.serviceName segeViewController:self];
}

- (void)rebuildHeight:(CGFloat)height currentFrame:(CGRect)currentFrame {
    CGSize size = CGSizeMake(WIN_WIDTH, CGRectGetMaxY(currentFrame) + height);
    [_verticalCanvas setContentSize:size];
    if (_subInfoDevices.count || _controlSubDevices.count) {
        [self.whiteView removeFromSuperview];
    }
}

- (void)buildSubDevices {
    _subInfoDevices = [NSMutableArray arrayWithArray:_gateway.subDevices];
    _controlSubDevices = [NSMutableArray arrayWithCapacity:1];
    
    XM_WS(weakself);
    [_gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *className = NSStringFromClass([sensor class]);
        if([className isEqualToString:@"MHDeviceGatewaySensorPlug"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorSingleNeutral"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorDoubleNeutral"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorCurtain"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorCassette"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorWithNeutralSingle"] ||
           [className isEqualToString:@"MHDeviceGatewaySensorWithNeutralDual"]
           ){
            [weakself.controlSubDevices addObject:sensor];
            [weakself.subInfoDevices removeObject:sensor];
        }
        if ([className isEqualToString:@"MHDeviceGatewaySensorXBulb"]) {
            [weakself.subInfoDevices removeObject:sensor];
        }
        
    }];
    
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

- (void)reBuildSubviews {
    XM_WS(weakself);
    [_gateway getSubDeviceListWithSuccess:^(id obj) {
        __block NSInteger deviceCount = weakself.gateway.subDevices.count;
        [weakself.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *className = NSStringFromClass([sensor class]);
            if ([className isEqualToString:@"MHDeviceGatewaySensorXBulb"]) {
                deviceCount--;
            }
        }];
        
        if ((weakself.subInfoDevices.count + weakself.controlSubDevices.count) == deviceCount) {
            return;
        }
        [weakself.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview removeFromSuperview];
        }];
        [weakself buildSubviews];
    } failuer:^(NSError *error) {
        
    }];
}

@end
