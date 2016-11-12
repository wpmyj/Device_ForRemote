//
//  MHACCoolSpeedHtBindViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACCoolSpeedHtBindViewController.h"
#import "MHDeviceGatewaySensorHumiture.h"

@interface MHACCoolSpeedHtBindViewController ()

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UIButton *determineBtn;

@property (nonatomic, strong) NSMutableArray *htDevices;
@property (nonatomic, strong) UILabel *noHtDevice;

@property (nonatomic, strong) MHDeviceGatewaySensorHumiture *sensorHt;
@property (nonatomic, copy) NSString *itemIdentify;
@property (nonatomic, assign) NSInteger coolSpan;

@end

@implementation MHACCoolSpeedHtBindViewController
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner htDid:(NSString *)did timeSpan:(NSInteger)timeSpan
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        self.itemIdentify = did;
        self.coolSpan = timeSpan;
        [self buildTitleArray];
    }
    return self;
}

- (void)buildTitleArray {
    XM_WS(weakself);
    self.htDevices = [NSMutableArray new];
    [self.acpartner.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass([sensor class]) isEqualToString:@"MHDeviceGatewaySensorHumiture"]) {
            if ([sensor.did isEqualToString:weakself.itemIdentify]) {
                weakself.sensorHt = (MHDeviceGatewaySensorHumiture *)sensor;
            }
            [weakself.htDevices addObject:sensor];
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.add",@"plugin_gateway","关联温湿度");
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self removewNotFoundSubDevicesView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

- (void)buildSubviews {
    [super buildSubviews];
    
    [self buildTableView];
    
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    [self.determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view.mas_bottom).with.offset(-12);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, 46));
    }];
    
}

- (void)buildTableView {
    XM_WS(weakself);
    
    if (self.htDevices.count) {
        [self.noHtDevice removeFromSuperview];
        MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
        
        MHDeviceSettingItem *item1 = [[MHDeviceSettingItem alloc] init];
        item1.identifier = kCoolNotBindHt;
        item1.type = MHDeviceSettingItemTypeCheckmark;
        item1.hasAcIndicator = [item1.identifier isEqualToString:self.itemIdentify];        
        item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.notconnect",@"plugin_gateway","未关联");
        item1.customUI = YES;
        item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item1.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself setCoolSpeedData:kCoolNotBindHt Success:^(id obj) {
                weakself.sensorHt = nil;
                weakself.itemIdentify = kCoolNotBindHt;
                [weakself buildTableView];
                if (weakself.htSelect) {
                    weakself.htSelect(weakself.itemIdentify);
                }
            } failure:^(NSError *v) {
                
            }];
        };
        [items addObject:item1];
        
        
        [self.htDevices enumerateObjectsUsingBlock:^(MHDeviceGatewaySensorHumiture *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
            MHDeviceSettingItem *item = [[MHDeviceSettingItem alloc] init];
            item.identifier = sensor.did;
            item.type = MHDeviceSettingItemTypeCheckmark;
            item.caption = sensor.name;
            item.hasAcIndicator = [item.identifier isEqualToString:weakself.sensorHt.did];
            item.customUI = YES;
            item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
            item.callbackBlock = ^(MHDeviceSettingCell *cell) {
                
                [weakself setCoolSpeedData:sensor.did Success:^(id obj) {
                    weakself.sensorHt = sensor;
                    weakself.itemIdentify = sensor.did;
                    [weakself buildTableView];
                    if (weakself.htSelect) {
                        weakself.htSelect(weakself.itemIdentify);
                    }
                } failure:^(NSError *v) {
                    
                }];
            };
            [items addObject:item];
        }];
        
        
        group1.items = items;
        
        self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
    }
    else {
        self.noHtDevice = [[UILabel alloc] init];
        self.noHtDevice.textAlignment = NSTextAlignmentCenter;
        self.noHtDevice.textColor = [UIColor blackColor];
        self.noHtDevice.font = [UIFont systemFontOfSize:16.0f];
        self.noHtDevice.numberOfLines = 0;
        self.noHtDevice.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.none",@"plugin_gateway","亲 , 该功能需要关联温湿度传感器, \n 可以在 设备 页添加哦~");
        [self.view addSubview:self.noHtDevice];
        
        [self.noHtDevice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakself.view);
            make.width.mas_equalTo(WIN_WIDTH - 20);
        }];
    }
    
    [self.settingTableView reloadData];
    
}

- (void)setCoolSpeedData:(NSString *)did Success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSMutableArray *payload = [[NSMutableArray alloc] init];
    [payload addObject:@(1)];
    [payload addObject:@(self.coolSpan)];
    [payload addObject:[did isEqualToString:kCoolNotBindHt] ? @"" : did];
    
    
    [self.acpartner setCoolSpeed:payload success:^(id obj) {
        [[MHTipsView shareInstance] hide];
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        NSLog(@"错误%@", error);
        if (failure) failure(error);
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];

//        [[MHTipsView shareInstance] showTipsInfo:@"跪了" duration:1.5 modal:YES];
    }];
    
}

@end
