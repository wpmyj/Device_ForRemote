//
//  MHGatewayCurtainLevelSettingViewController.m
//  MiHome
//
//  Created by guhao on 16/1/11.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCurtainLevelSettingViewController.h"

@interface MHGatewayCurtainLevelSettingViewController ()

@end

@implementation MHGatewayCurtainLevelSettingViewController

- (instancetype)initWithDevice:(MHDeviceGatewaySensorCurtain *)deviceCurtain
{
    self = [super init];
    if (self) {
        self.curtain = deviceCurtain;
        [self openLevelSetting];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustCurtainLevelItems];
}


- (void)openLevelSetting {
    XM_WS(weakself);
    MHLuDeviceSettingGroup* groupSelHoldTime = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainLevelItems = [NSMutableArray arrayWithCapacity:1];
    groupSelHoldTime.items = curtainLevelItems;
    groupSelHoldTime.title = nil;
    
    MHDeviceSettingItem *levelItem10 = [[MHDeviceSettingItem alloc] init];
    levelItem10.identifier = @"levelItem10";
    levelItem10.type = MHDeviceSettingItemTypeCheckmark;
    levelItem10.caption = @"100%";
    levelItem10.hasAcIndicator = (self.curtain.curtain_level == Gateway_Level_Curtain_100);
    levelItem10.customUI = YES;
    levelItem10.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    levelItem10.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (cell.item.hasAcIndicator) {
            return;
        }
        [weakself.curtain setCurtainProperty:100 andSuccess:^(id obj) {
            NSLog(@"设置成功%@", obj);

        } failure:^(NSError *error) {
            NSLog(@"设置开关比错误%@", error);
        }];
        [self adjustCurtainLevelItems];
        [cell finish];

    };
    [curtainLevelItems addObject:levelItem10];
    
    MHDeviceSettingItem *levelItem9 = [[MHDeviceSettingItem alloc] init];
    levelItem9.identifier = @"levelItem9";
    levelItem9.type = MHDeviceSettingItemTypeCheckmark;
    levelItem9.caption = @"90%";
    levelItem9.hasAcIndicator = (self.curtain.curtain_level == Gateway_Level_Curtain_90);
    levelItem9.customUI = YES;
    levelItem9.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    levelItem9.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (cell.item.hasAcIndicator) {
            return;
        }
        weakself.curtain.curtain_level = 90;
        [weakself.curtain setCurtainProperty:90 andSuccess:^(id obj) {
            NSLog(@"设置成功%@", obj);
            
        } failure:^(NSError *error) {
            NSLog(@"设置开关比错误%@", error);
        }];
        [self adjustCurtainLevelItems];
        [cell finish];

    };
    [curtainLevelItems addObject:levelItem9];
    
    MHDeviceSettingItem *levelItem8 = [[MHDeviceSettingItem alloc] init];
    levelItem8.identifier = @"levelItem8";
    levelItem8.type = MHDeviceSettingItemTypeCheckmark;
    levelItem8.caption = @"80%";
    levelItem8.hasAcIndicator = (self.curtain.curtain_level == Gateway_Level_Curtain_80);
    levelItem8.customUI = YES;
    levelItem8.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    levelItem8.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (cell.item.hasAcIndicator) {
            return;
        }
        weakself.curtain.curtain_level = 80;
        [weakself.curtain setCurtainProperty:80 andSuccess:^(id obj) {
            NSLog(@"设置成功%@", obj);
            
        } failure:^(NSError *error) {
            NSLog(@"设置开关比错误%@", error);
        }];

        [self adjustCurtainLevelItems];
        [cell finish];

    };
    [curtainLevelItems addObject:levelItem8];
    
    MHDeviceSettingItem *levelItem7 = [[MHDeviceSettingItem alloc] init];
    levelItem7.identifier = @"levelItem7";
    levelItem7.type = MHDeviceSettingItemTypeCheckmark;
    levelItem7.caption = @"70%";
    levelItem7.hasAcIndicator = (self.curtain.curtain_level == Gateway_Level_Curtain_70);
    levelItem7.customUI = YES;
    levelItem7.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    levelItem7.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (cell.item.hasAcIndicator) {
            return;
        }
        weakself.curtain.curtain_level = 70;
        [weakself.curtain setCurtainProperty:70 andSuccess:^(id obj) {
            NSLog(@"设置成功%@", obj);
            
        } failure:^(NSError *error) {
            NSLog(@"设置开关比错误%@", error);
        }];

        [self adjustCurtainLevelItems];
        [cell finish];

    };
    [curtainLevelItems addObject:levelItem7];
    
    MHDeviceSettingItem *levelItem6 = [[MHDeviceSettingItem alloc] init];
    levelItem6.identifier = @"levelItem6";
    levelItem6.type = MHDeviceSettingItemTypeCheckmark;
    levelItem6.caption = @"60%";
    levelItem6.hasAcIndicator = (self.curtain.curtain_level == Gateway_Level_Curtain_60);
    levelItem6.customUI = YES;
    levelItem6.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    levelItem6.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (cell.item.hasAcIndicator) {
            return;
        }
        weakself.curtain.curtain_level = 60;
        [weakself.curtain setCurtainProperty:60 andSuccess:^(id obj) {
            NSLog(@"设置成功%@", obj);
            
        } failure:^(NSError *error) {
            NSLog(@"设置开关比错误%@", error);
        }];

        [self adjustCurtainLevelItems];
        [cell finish];

    };
    [curtainLevelItems addObject:levelItem6];

    MHDeviceSettingItem *levelItem5 = [[MHDeviceSettingItem alloc] init];
    levelItem5.identifier = @"levelItem5";
    levelItem5.type = MHDeviceSettingItemTypeCheckmark;
    levelItem5.caption = @"50%";
    levelItem5.hasAcIndicator = (self.curtain.curtain_level == Gateway_Level_Curtain_50);
    levelItem5.customUI = YES;
    levelItem5.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    levelItem5.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (cell.item.hasAcIndicator) {
            return;
        }
//        [weakself.curtain setpropertyWithCurtainLevel:Gateway_Level_Curtain_50 Success:^(id obj) {
//            [weakself adjustCurtainLevelItems];
//            [cell finish];
//            [[MHTipsView shareInstance] hide];
//        } andFailure:^(NSError *error) {
//             [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
//            [cell finish];
//        }];
        [weakself.curtain setCurtainProperty:100 andSuccess:^(id obj) {
            NSLog(@"设置成功%@", obj);
            
        } failure:^(NSError *error) {
            NSLog(@"设置开关比错误%@", error);
        }];

//        weakself.curtain.curtain_level = 50;
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];

    };
    [curtainLevelItems addObject:levelItem5];
    
    MHDeviceSettingItem *levelItem4 = [[MHDeviceSettingItem alloc] init];
    levelItem4.identifier = @"levelItem4";
    levelItem4.type = MHDeviceSettingItemTypeCheckmark;
    levelItem4.caption = @"40%";
    levelItem4.hasAcIndicator = (self.curtain.curtain_level == Gateway_Level_Curtain_40);
    levelItem4.customUI = YES;
    levelItem4.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    levelItem5.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (cell.item.hasAcIndicator) {
            return;
        }
        weakself.curtain.curtain_level = 40;
        [self adjustCurtainLevelItems];
        [cell finish];
    };
    [curtainLevelItems addObject:levelItem4];
    self.settingGroups = @[groupSelHoldTime];
    [self adjustCurtainLevelItems];
}

//- (void)updateCurtainLevelItems {
//    MHDeviceSettingItem* itemHoldTime = [self itemWithIdentifier:@"itemHoldTime"];
////    itemHoldTime.comment = [self alarmDelayString];
//    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"itemHoldTime"] atSection:3];
//}

- (void)adjustCurtainLevelItems {
    MHDeviceSettingItem* item10 = [self itemWithIdentifier:@"levelItem10"];
    item10.hasAcIndicator = NO;
    MHDeviceSettingItem* item9 = [self itemWithIdentifier:@"levelItem9"];
    item9.hasAcIndicator = NO;
    MHDeviceSettingItem* item8 = [self itemWithIdentifier:@"levelItem8"];
    item8.hasAcIndicator = NO;
    MHDeviceSettingItem* item7 = [self itemWithIdentifier:@"levelItem7"];
    item7.hasAcIndicator = NO;
    MHDeviceSettingItem* item6 = [self itemWithIdentifier:@"levelItem6"];
    item6.hasAcIndicator = NO;
    MHDeviceSettingItem* item5 = [self itemWithIdentifier:@"levelItem5"];
    item5.hasAcIndicator = NO;
    MHDeviceSettingItem* item4 = [self itemWithIdentifier:@"levelItem4"];
    item4.hasAcIndicator = NO;
    switch (self.curtain.curtain_level) {
        case Gateway_Level_Curtain_100: {
            item10.hasAcIndicator = YES;
        }
            break;
        case Gateway_Level_Curtain_90: {
            item9.hasAcIndicator = YES;
        }
            break;
        case Gateway_Level_Curtain_80: {
            item8.hasAcIndicator = YES;
        }
            break;
        case Gateway_Level_Curtain_70: {
            item7.hasAcIndicator = YES;
        }
            break;
        case Gateway_Level_Curtain_60: {
            item6.hasAcIndicator = YES;
        }
            break;
        case Gateway_Level_Curtain_50: {
            item5.hasAcIndicator = YES;
        }
            break;
        case Gateway_Level_Curtain_40: {
            item4.hasAcIndicator = YES;
        }
            break;
        default:
            break;
    }
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"levelItem10"] atSection:0];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"levelItem9"] atSection:0];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"levelItem8"] atSection:0];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"levelItem7"] atSection:0];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"levelItem6"] atSection:0];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"levelItem5"] atSection:0];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"levelItem4"] atSection:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
