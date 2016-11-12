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
    
    self.title = @"报警灵敏度设置";
}

- (void)buildSubviews {
    [super buildSubviews];
    [self buildTableView];
}

- (void)buildTableView {
    XM_WS(weakself);
    
    
    //    NSString* strIfttt = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    //    NSString* strInstallation = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.installationtutorial",@"plugin_gateway","安装教程");
    NSString* strHighCaption = @"高";
    NSString* strMiddleCaption = nil;
    NSString* strLowCaption = @"低";
    NSString* strHighComment = nil;
    NSString* strMiddleComment = nil;
    NSString* strLowComment = nil;
    if ([NSStringFromClass([self.deviceNatgas class]) isEqualToString:@"MHDeviceGatewaySensorNatgas"]){
        strMiddleCaption = @"中(推荐)";
        strHighComment = @"极少气体即可报警";
        strMiddleComment = @"少许气体即可报警";
        strLowComment = @"一些气体即可报警";
    }else if ([NSStringFromClass([self.deviceNatgas class]) isEqualToString:@"MHDeviceGatewaySensorSmoke"]){
        strMiddleCaption = @"中";
        strHighComment = @"适合无烟尘区(如客厅、办公室、仓库)";
        strMiddleComment = @"适合无烟尘区(如有人吸烟的客厅)";
        strLowComment = @"适合中量烟尘区(如厨房)";
    }

    
    //    NSString* strSelfTest = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice",@"plugin_gateway","方向选择");
    
    
    //    NSString* strSelfTestCaption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.clearitinerary",@"plugin_gateway","清楚行程(慎点)");
    //    NSString* strSelfTestComment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.manualcontrol",@"plugin_gateway","手动开/关窗帘");
  
    
    
    
    
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
    [[MHTipsView shareInstance] showTips:@"保存配置中……" modal:YES];
    
    __block NSInteger count = 0;
    
    [self setSensitivityBlock:^{
        XM_SS(strongself, weakself);
        // 延迟一秒设置灵敏度
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
                    [[MHTipsView shareInstance] showTipsInfo:@"失败请检查网络" duration:1.5f modal:YES];
                }
                
                
            } failure:^(NSError *error) {
                [[MHTipsView shareInstance] showTipsInfo:@"失败请检查网络" duration:1.5f modal:YES];
                if (failure) failure(error);
            }];
        });
        count += 1;
    }];
    
    
    self.sensitivityBlock();
}

@end
