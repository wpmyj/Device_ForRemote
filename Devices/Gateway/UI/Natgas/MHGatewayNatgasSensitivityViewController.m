//
//  MHGatewayNatgasSensitivityViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayNatgasSensitivityViewController.h"

@interface MHGatewayNatgasSensitivityViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorNatgas *deviceNatgas;
@property (nonatomic, copy) void (^sensitivityBlock)(void);

@end

@implementation MHGatewayNatgasSensitivityViewController
- (id)initWithDeviceNatgas:(MHDeviceGatewaySensorNatgas *)deviceNatgas
{
    self = [super init];
    if (self) {
        self.deviceNatgas = deviceNatgas;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive", @"plugin_gateway", @"报警灵敏度");
}

- (void)buildSubviews {
    [super buildSubviews];
    [self buildTableView];
}

- (void)buildTableView {
    XM_WS(weakself);
    NSString* strHighCaption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.high", @"plugin_gateway", @"高");
    NSString* strMiddleCaption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.medium", @"plugin_gateway", @"中");
    NSString* strLowCaption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.low", @"plugin_gateway", @"低");
    NSString* strHighComment = nil;
    NSString* strMiddleComment = nil;
    NSString* strLowComment = nil;
    if ([NSStringFromClass([self.deviceNatgas class]) isEqualToString:@"MHDeviceGatewaySensorNatgas"]){
        strMiddleCaption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.medium", @"plugin_gateway", @"中(推荐)");
        strHighComment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.highcomment", @"plugin_gateway", @"高");
        strMiddleComment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.mediumcomment", @"plugin_gateway", @"中");
        strLowComment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.lowcomment", @"plugin_gateway", @"低");
    }else if ([NSStringFromClass([self.deviceNatgas class]) isEqualToString:@"MHDeviceGatewaySensorSmoke"]){
        strMiddleCaption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive.low", @"plugin_gateway", @"低");
        strHighComment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.smoke.sensitive.highcomment", @"plugin_gateway", @"高");
        strMiddleComment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.smoke.sensitive.mediumcomment", @"plugin_gateway", @"中");
        strLowComment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.smoke.sensitive.lowcomment", @"plugin_gateway", @"低");
    }
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainSettings = [NSMutableArray new];
    
    //报警灵敏度
    MHDeviceSettingItem *itemHigh = [[MHDeviceSettingItem alloc] init];
    itemHigh.identifier = @"mydevice.gateway.sensor.curtain.installationtutorial";
    itemHigh.type = MHDeviceSettingItemTypeCheckmark;
    itemHigh.hasAcIndicator = self.deviceNatgas.sensitivity == HIGH_INDEX ? YES : NO;
    itemHigh.caption = strHighCaption;
    itemHigh.comment = strHighComment;
    itemHigh.customUI = YES;
    itemHigh.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemHigh.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself setSensitivity:HIGH_INDEX Success:nil failure:nil];
    };
    [curtainSettings addObject:itemHigh];
  
    //报警灵敏度
    MHDeviceSettingItem *itemMiddle = [[MHDeviceSettingItem alloc] init];
    itemMiddle.identifier = @"mydevice.gateway.sensor.curtain.installationtutorial";
    itemMiddle.type = MHDeviceSettingItemTypeCheckmark;
    itemMiddle.hasAcIndicator = self.deviceNatgas.sensitivity == MIDDLE_INDEX ? YES : NO;
    itemMiddle.caption = strMiddleCaption;
    itemMiddle.comment = strMiddleComment;
    itemMiddle.customUI = YES;
    itemMiddle.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemMiddle.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself setSensitivity:MIDDLE_INDEX Success:nil failure:nil];
    };
    [curtainSettings addObject:itemMiddle];

    //报警灵敏度
    MHDeviceSettingItem *itemLow = [[MHDeviceSettingItem alloc] init];
    itemLow.identifier = @"mydevice.gateway.sensor.curtain.installationtutorial";
    itemLow.type = MHDeviceSettingItemTypeCheckmark;
    itemLow.hasAcIndicator = self.deviceNatgas.sensitivity == LOW_INDEX ? YES : NO;
    itemLow.caption = strLowCaption;
    itemLow.comment = strLowComment;
    itemLow.customUI = YES;
    itemLow.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemLow.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself setSensitivity:LOW_INDEX Success:nil failure:nil];
    };
    [curtainSettings addObject:itemLow];
    
    group1.items = curtainSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
}

- (void)setSensitivity:(Natgas_Prop_Id)propID Success:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting", @"plugin_gateway", @"设置中，请稍候...") modal:YES];
    
    __block NSInteger count = 0;
    
    [self setSensitivityBlock:^{
        XM_SS(strongself, weakself);
        //延迟一秒设置灵敏度
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [weakself.deviceNatgas setPrivateProperty:propID value:nil success:^(id obj) {
                if (!([[obj[@"result"] firstObject] isKindOfClass:[NSString class]] && [[obj[@"result"] firstObject] isEqualToString:@"waiting"])) {
                    [weakself buildTableView];
                    [[MHTipsView shareInstance] hide];
                    if (success) success(obj);
                    return;
                }
                if (count < 18) {
                    //烟感有15s休眠
                    if (weakself.sensitivityBlock) {
                        weakself.sensitivityBlock();
                    }
                }
                else {
                    if (failure) failure(nil);
                    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", @"设置失败") modal:YES];
                }
                
            } failure:^(NSError *error) {
                [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", @"设置失败") modal:YES];
                if (failure) failure(error);
            }];
        });
        count += 1;
    }];
    
    self.sensitivityBlock();
}

@end
