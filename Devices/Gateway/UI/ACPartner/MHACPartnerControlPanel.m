//
//  MHACPartnerControlPanel.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerControlPanel.h"
#import "MHDeviceGatewaySensorPlug.h"
#import "MHDeviceGatewaySensorDoubleNeutral.h"
#import "MHDeviceGatewaySensorSingleNeutral.h"
#import "MHDeviceGatewaySensorSingleSwitch.h"
#import "MHDeviceGatewaySensorDoubleSwitch.h"
#import "MHDeviceGatewaySensorCassette.h"
#import "MHWaveAnimation.h"
#import "MHDeviceChangeNameView.h"
#import "MHLumiChangeIconManager.h"
#import "MHLumiChooseLogoListManager.h"

#define CellHeight 75.f
//循环请求间隔
#define LoopDataInterval        8.0

@interface MHACPartnerControlPanel ()


@property (nonatomic,strong) MHDeviceAcpartner *acpartner;
@property (nonatomic,strong) NSMutableArray *controlDevices;
@property (nonatomic,strong) NSMutableArray *controlServices;
@property (nonatomic,strong) NSMutableArray *reloadSubviewArray;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSInteger longPressedServiceIndex;

@end

@implementation MHACPartnerControlPanel


- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner *)acpartner subDevices:(NSArray *)subDevices{
    if (self = [super initWithFrame:frame]) {
        self.acpartner = acpartner;
        _controlDevices = [NSMutableArray arrayWithArray:subDevices];
        _reloadSubviewArray = [NSMutableArray new];
        _longPressedServiceIndex = -1;
//        [self fetchStatus];
        [self fetchServices];
        [self buildSubviews];
    }
    return self;
}

- (void)dealloc {
    [self stopWatchingDeviceStatus];
}

- (void)fetchServices {
    _controlServices = [NSMutableArray new];
    for (MHDeviceGatewayBase *sensor in _controlDevices){
        [sensor buildServices];
        [_controlServices addObjectsFromArray:sensor.services];
    }
}

- (void)buildSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 36)];
    sectionView.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
    [self addSubview:sectionView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 80, 20)];
    titleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    titleLabel.font = [UIFont systemFontOfSize:13.f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.panel.control", @"plugin_gateway", nil);
    [self addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 36, WIN_WIDTH, 0.7)];
    line.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
    [self addSubview:line];
    
    XM_WS(weakself);
    [_controlServices enumerateObjectsUsingBlock:^(MHDeviceGatewayBaseService *service, NSUInteger idx, BOOL *stop) {
        [weakself buildSensorView:service withIndex:idx];
    }];
}

#pragma mark - 创建子设备控制视图
- (void)buildSensorView:(MHDeviceGatewayBaseService *)service withIndex:(NSInteger)index {
    CGFloat width = 0.25 * WIN_WIDTH;
    CGFloat x = index % 4 * width;
    CGFloat y = index / 4 * CellHeight + 37;
    CGRect canvasViewFrame = CGRectMake(x , y, width, CellHeight);
    UIView *canvasView = [[UIView alloc] initWithFrame:canvasViewFrame];
    canvasView.tag = index;
    canvasView.backgroundColor = [UIColor clearColor];
    [self addSubview:canvasView];
    
    UIButton *iconViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 20, 8, 45, 45)];
    iconViewBtn.tag = index;
    [iconViewBtn addTarget:self action:@selector(deviceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [iconViewBtn setImage:service.serviceIcon forState:UIControlStateNormal];
    [iconViewBtn setEnabled:!service.isDisable];
    [canvasView addSubview:iconViewBtn];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:14.f];
    nameLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.f];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.frame = CGRectMake(2, 53, CGRectGetWidth(canvasView.frame), 20);
    [canvasView addSubview:nameLabel];
    [nameLabel setEnabled:!service.isDisable];
    nameLabel.text = service.serviceName;
    
    CGRect selfFrame = self.frame;
    CGFloat sX = CGRectGetMinX(selfFrame);
    CGFloat sY = CGRectGetMinY(selfFrame);
    CGFloat sWidth = CGRectGetWidth(selfFrame);
    self.frame = CGRectMake(sX, sY, sWidth, y + CellHeight);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deviceTaped:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [canvasView addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPress.minimumPressDuration = 1.3f;
    [canvasView addGestureRecognizer:longPress];
    
    MHWaveAnimation *waveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    waveAnimation.waveInterval = 0.5f;
    waveAnimation.singleWaveScale = 1.5f;
    [canvasView addSubview:waveAnimation];
    
    NSMutableDictionary *viewDic = [NSMutableDictionary new];
    [viewDic setObject:iconViewBtn forKey:@"iconViewBtn"];
    [viewDic setObject:nameLabel forKey:@"nameLabel"];
    [viewDic setObject:canvasView forKey:@"canvasView"];
    [viewDic setObject:waveAnimation forKey:@"waveAnimation"];
    [self.reloadSubviewArray addObject:viewDic];
}

- (void)reloadView {
    XM_WS(weakself);
    [self.controlServices enumerateObjectsWithOptions:NSEnumerationConcurrent
                                           usingBlock:^(MHDeviceGatewayBaseService  *service, NSUInteger idx, BOOL *stop) {
                                               if(weakself.reloadSubviewArray.count > idx){
                                                   NSDictionary *viewDic = weakself.reloadSubviewArray[idx];
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       
                                                       UILabel *nameLabel = (UILabel *)[viewDic valueForKey:@"nameLabel"];
                                                       UIButton *iconViewBtn = (UIButton *)[viewDic valueForKey:@"iconViewBtn"];
                                                       
                                                       if(![nameLabel.text isEqualToString:service.serviceName]){
                                                           nameLabel.text = service.serviceName;
                                                           [nameLabel setEnabled:!service.isDisable];
                                                       }
                                                       
                                                       [iconViewBtn setEnabled:!service.isDisable];
                                                       if(!service.isDisable) [iconViewBtn setImage:service.serviceIcon forState:UIControlStateNormal];
                                                   });
                                               }
                                           }];
}


#pragma mark - 获取状态并刷新
- (void)startWatchingDeviceStatus {
    if (self.shouldKeepRunning) {
        return;
    }
    self.shouldKeepRunning = YES;
    
    XM_WS(weakself);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakself.timer = [NSTimer timerWithTimeInterval:LoopDataInterval
                                                 target:self
                                               selector:@selector(fetchStatus)
                                               userInfo:nil
                                                repeats:YES];
        [weakself.timer fire];
        
        NSRunLoop *currentRL = [NSRunLoop currentRunLoop];
        [currentRL addTimer:weakself.timer forMode:NSDefaultRunLoopMode];
        while (weakself.shouldKeepRunning && [currentRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    });
}

- (void)stopWatchingDeviceStatus {
    NSLog(@" ------ finished ------ ");
    [self.timer invalidate];
    self.timer = nil;
    self.shouldKeepRunning = NO;
}

- (void)fetchStatus {
    NSLog(@" ------ fetchStatus ------ ");
    
    XM_WS(weakself);
    
    NSInteger propIndex = _controlDevices.count / kMAXDEVICESPROPCOUNT + 1;
    if (!_controlDevices.count) {
        return;
    }
    
    for (NSInteger i = 0; i < propIndex; i++) {
        NSMutableArray *devices = [NSMutableArray new];
        for (NSInteger idx = i * kMAXDEVICESPROPCOUNT; idx < (i + 1) * kMAXDEVICESPROPCOUNT; idx++) {
            if (idx >= _controlDevices.count) {
                break;
            }
            [devices addObject:_controlDevices[idx]];
        }
        
        [_acpartner gePropDevices:devices success:^(id obj) {
            [weakself fetchServices];
            //通知主线程刷新
            [weakself reloadView];
            
            
        } failure:^(NSError *error) {
            
        }];
    }
    
}

#pragma mark - device control
- (void)deviceTaped:(UITapGestureRecognizer *)gesture {
    [self clickAciton:gesture.view.tag];
}

- (void)clickAciton:(NSInteger)index {
    XM_WS(weakself);
    
    MHDeviceGatewayBaseService *service = _controlServices[index];
    if(service.isOnline){
        service.serviceMethodSuccess = ^(id obj){
            [weakself clickedFinished:index];
            [weakself reloadView];
        };
        service.serviceMethodFailure = ^(NSError *error){
            [weakself clickedFinished:index];
            [weakself reloadView];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.offlineview.networkfail.tips", @"plugin_gateway", nil) duration:1.5f modal:NO];
        };
        [service serviceMethod];
        [weakself reloadView];
        [self clickedStarted:index];
    }
    else{
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.offlineview.just.tips", @"plugin_gateway", nil) duration:1.5f modal:NO];
    }
}

- (void)deviceBtnClicked:(UIButton *)btn{
    [self clickAciton:btn.tag];
}

- (void)clickedStarted:(NSInteger)index {
    NSDictionary *viewDic = self.reloadSubviewArray[index];
    UIView *canvasView = (UIView *)[viewDic valueForKey:@"canvasView"];
    canvasView.userInteractionEnabled = NO;
    UIButton *iconViewBtn = (UIButton *)[viewDic valueForKey:@"iconViewBtn"];
    [iconViewBtn setEnabled:NO];
    
    [self setWaveAnim:YES forBtn:iconViewBtn withIndex:index];
}

- (void)clickedFinished:(NSInteger)index {
    XM_WS(weakself);
    MHDeviceGatewayBaseService *service = _controlServices[index];
    if([service.serviceParentClass isEqualToString:@"MHDeviceGatewaySensorDoubleNeutral"] ||
       [service.serviceParentClass isEqualToString:@"MHDeviceGatewaySensorSingleNeutral"] ){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself fetchStatus];
            [weakself waveStoped:index];
        });
    }
    else{
        [weakself waveStoped:index];
    }
}

- (void)waveStoped:(NSInteger)index {
    NSDictionary *viewDic = self.reloadSubviewArray[index];
    
    UIView *canvasView = (UIView *)[viewDic valueForKey:@"canvasView"];
    canvasView.userInteractionEnabled = YES;
    UIButton *iconViewBtn = (UIButton *)[viewDic valueForKey:@"iconViewBtn"];
    [iconViewBtn setEnabled:YES];
    iconViewBtn.selected = !iconViewBtn.selected;
    
    [self setWaveAnim:NO forBtn:iconViewBtn withIndex:index];
}

#pragma mark - wave animation
- (void)setWaveAnim:(BOOL)anim forBtn:(UIButton*)btn withIndex:(NSInteger)index {
    NSDictionary *viewDic = self.reloadSubviewArray[index];
    MHWaveAnimation *waveAnimation = (MHWaveAnimation *)[viewDic valueForKey:@"waveAnimation"];
    
    if ([btn isSelected]) {
        waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x888888];
    }
    else {
        waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x3FB57D];
    }
    [waveAnimation setFrame:[btn frame]];
    if (anim){
        [waveAnimation startAnimation];
    }
    else{
        [waveAnimation stopAnimation];
    }
}

#pragma mark - long press
- (void)longPressed:(UILongPressGestureRecognizer *)gesture {
    MHDeviceGatewayBaseService *service = _controlServices[gesture.view.tag];
    if(service.isOnline){
        if(gesture.state == UIGestureRecognizerStateBegan)
            [self longPressAciton:gesture.view.tag];
    }
    else {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.offlineview.just.tips", @"plugin_gateway", nil) duration:1.5f modal:NO];
    }
}

- (void)longPressAciton:(NSInteger)index {
    _longPressedServiceIndex = index;
    MHDeviceGatewayBaseService *service = _controlServices[_longPressedServiceIndex];
  
    
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    
    NSString* strChooseIcon = NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo", @"plugin_gateway", @"换图标");
    
    NSString* strMore = NSLocalizedStringFromTable(@"mydevice.actionsheet.more", @"plugin_gateway", @"更多");
    
    NSArray *titlesArray = @[ strChangeTitle, strChooseIcon, strMore ];
    
    XM_WS(weakself);
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [[MHPromptKit shareInstance] showPromptInView:window withHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
                //取消
                break;
            }
            case 1: {
                //重命名
                [weakself changeName];
                break;
            }
            case 2: {
                //温湿度历史
                [weakself changLogo];
                
                break;
            }
            case 3: {
                //打开设备页
                if(self.openDevicePageCallback)self.openDevicePageCallback(service);
                break;
            }
            default:
                break;
        }
    } withTitle:service.serviceName cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") destructiveButtonTitle:nil otherButtonTitlesArray:titlesArray];

}

#pragma mark - change service
- (void)changLogo {
    XM_WS(weakself);
    __block MHDeviceGatewayBaseService *oldService = _controlServices[_longPressedServiceIndex];
    
    NSString *iconId = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:oldService
                                                                 withCompletionHandler:^(id result, NSError *error){}];
    oldService.serviceIconId = iconId;
    if(self.chooseServiceIcon) self.chooseServiceIcon(oldService);
    MHLumiChooseLogoListManager *logoChooseManager = [MHLumiChooseLogoListManager sharedInstance];
    logoChooseManager.setIconSuccessed = ^(MHDeviceGatewayBaseService *service){
        oldService = service;
        [oldService changeIcon];
        [weakself reloadView];
    };
}

- (void)changeName {
    XM_WS(weakself);
    
    __block MHDeviceGatewayBaseService *service = _controlServices[_longPressedServiceIndex];
    __block NSString *newServiceName ;
    CGFloat ratio = [UIScreen mainScreen].bounds.size.width / 414.0f;
    MHDeviceChangeNameView* changeNameView = [[MHDeviceChangeNameView alloc] initWithFrame:[UIScreen mainScreen].bounds panelFrame:CGRectMake(20 * ratio, 100, ([UIScreen mainScreen].bounds.size.width-40 * ratio), 195 * ratio) withCancel:^(id object){
    } withOk:^(NSString* newName){
        newServiceName = newName;
        service.serviceName = newName;
        [service changeName];
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","nil") modal:NO];
    }];
    [changeNameView setName:service.serviceName];
    [self.window addSubview:changeNameView];
    
    service.serviceChangeNameFailure = ^(NSError *error){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.failed",@"plugin_gateway","修改设备名称失败") duration:1.0 modal:NO];
        [weakself reloadView];
    };
    service.serviceChangeNameSuccess = ^(id obj){
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.succeed",@"plugin_gateway","修改设备名称成功") duration:1.0 modal:NO];
        MHDeviceGatewayBaseService *service = weakself.controlServices[weakself.longPressedServiceIndex];
        service.serviceName = newServiceName;
        [weakself reloadView];
    };
}

@end
