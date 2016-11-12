//
//  MHACSleepEndSettingViewController.m
//  MiHome
//
//  Created by ayanami on 8/30/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHACSleepEndSettingViewController.h"
#import "MHLumiAccessSettingCell.h"
#import "MHGatewayAlarmDurationPicker.h"

@interface MHACSleepEndSettingViewController ()

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, assign) NSUInteger delayTime;
@property (nonatomic, strong) MHGatewayAlarmDurationPicker *durationPickerView;

@end


@implementation MHACSleepEndSettingViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner endType:(NSUInteger)type
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        _acpartner = acpartner;
        _type = type;
        _delayTime = 5;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.caption",@"plugin_gateway","睡眠模式");
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    [self buildTableView];
    
    XM_WS(weakself);
    self.durationPickerView = [[MHGatewayAlarmDurationPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom",@"plugin_gateway","自定义") durationPicked:^(NSUInteger duration) {
        weakself.delayTime = duration;
        [weakself buildTableView];
        if (weakself.endSetBlock) {
            weakself.endSetBlock(weakself.type, weakself.delayTime);
        }
    } pickerType:MHLMPickerType_Minute];
}

- (void)buildTableView {
    XM_WS(weakself);
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *endSettings = [NSMutableArray new];
    
    MHDeviceSettingItem *staySetting = [[MHDeviceSettingItem alloc] init];
    staySetting.identifier = @"sleepSwitch";
    staySetting.type = MHDeviceSettingItemTypeCheckmark;
    staySetting.hasAcIndicator = !self.type;
//    staySetting.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.caption",@"plugin_gateway","保持现状");
    staySetting.caption = @"保持现状";
    staySetting.customUI = YES;
    staySetting.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    staySetting.callbackBlock = ^(MHDeviceSettingCell *cell) {
        weakself.type = 0;
        [weakself buildTableView];
        if (weakself.endSetBlock) {
            weakself.endSetBlock(weakself.type, weakself.delayTime);
        }
    };
    
    [endSettings addObject:staySetting];
    
    
    
    MHDeviceSettingItem *offSetting = [[MHDeviceSettingItem alloc] init];
    offSetting.identifier = @"sleepSwitch";
    offSetting.type = MHDeviceSettingItemTypeCheckmark;
    offSetting.hasAcIndicator = self.type == 1 ? YES : NO;
//    offSetting.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.caption",@"plugin_gateway","睡眠模式");
    offSetting.caption = @"关闭空调";
    offSetting.customUI = YES;
    offSetting.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    offSetting.callbackBlock = ^(MHDeviceSettingCell *cell) {
        weakself.type = 1;
        [weakself buildTableView];
        if (weakself.endSetBlock) {
            weakself.endSetBlock(weakself.type, weakself.delayTime);
        }
    };
    
    [endSettings addObject:offSetting];

    
    if (self.type == 1) {
        //延迟关闭时间
        MHLumiSettingCellItem *itemSwept = [[MHLumiSettingCellItem alloc] init];
        itemSwept.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
        itemSwept.lumiType = MHLumiSettingItemTypeAccess;
        itemSwept.hasAcIndicator = YES;
        //    itemSwept.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist",@"plugin_gateway","子设备");
        itemSwept.caption = @"延迟关闭时间";
        itemSwept.comment = [NSString stringWithFormat:@"%ld", self.delayTime];
        itemSwept.customUI = YES;
        itemSwept.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
        itemSwept.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
            [weakself.durationPickerView setDuration:weakself.delayTime];
            [weakself.durationPickerView showInView:weakself.view.window];
        };
        [endSettings addObject:itemSwept];
    }
   
    group1.items = endSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];

}

@end
