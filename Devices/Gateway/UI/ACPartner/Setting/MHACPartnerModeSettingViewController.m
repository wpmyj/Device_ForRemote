//
//  MHACPartnerModeSettingViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerModeSettingViewController.h"

@interface MHACPartnerModeSettingViewController ()

@property (nonatomic, assign) int mode;
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@end

@implementation MHACPartnerModeSettingViewController


- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner currentMode:(int)mode;
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        self.mode = mode;
        _isSleep = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式");
    
}

- (void)buildSubviews {
    [super buildSubviews];
    [self dataConstruct];

}

-(void)dataConstruct{
    
    XM_WS(weakself);
    MHLuDeviceSettingGroup* groupModeChoice = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *modeItems = [NSMutableArray arrayWithCapacity:1];
    groupModeChoice.items = modeItems;
    groupModeChoice.title = nil;
    
    //    NSString *strForward = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.forward",@"plugin_gateway","正向");
    //    NSString *strReverse = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.reverse",@"plugin_gateway","反向");
    
    

#pragma mark -no
    MHDeviceSettingItem *itemForward = [[MHDeviceSettingItem alloc] init];
    itemForward.identifier = @"mydevice.gateway.sensor.acpartner.mode.cool";
    itemForward.type = MHDeviceSettingItemTypeCheckmark;
    //    itemForward.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.forward",@"plugin_gateway","正向");
    itemForward.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.cool",@"plugin_gateway","制冷");
    itemForward.hasAcIndicator = self.mode == AC_MODE_COOL;
    itemForward.customUI = YES;
    itemForward.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemForward.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (weakself.chooseMode) {
            weakself.chooseMode(AC_MODE_COOL);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
    };
    
    [modeItems addObject:itemForward];
    
    
  
    //制热
    MHDeviceSettingItem *itemHeat = [[MHDeviceSettingItem alloc] init];
    itemHeat.identifier = @"mydevice.gateway.sensor.acpartner.mode.heat";
    itemHeat.type = MHDeviceSettingItemTypeCheckmark;
    itemHeat.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.heat",@"plugin_gateway","制热");
    itemHeat.hasAcIndicator = self.mode == AC_MODE_HEAT;
    itemHeat.customUI = YES;
    itemHeat.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemHeat.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (weakself.chooseMode) {
            weakself.chooseMode(AC_MODE_HEAT);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
    };
    
    [modeItems addObject:itemHeat];
    
    
    if (!self.isSleep) {
        //自动
        MHDeviceSettingItem *itemReverse = [[MHDeviceSettingItem alloc] init];
        itemReverse.identifier = @"mydevice.gateway.sensor.acpartner.mode.auto";
        itemReverse.type = MHDeviceSettingItemTypeCheckmark;
        //    itemReverse.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.reverse",@"plugin_gateway","反向");
        itemReverse.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.auto",@"plugin_gateway","自动");
        itemReverse.hasAcIndicator = self.mode == AC_MODE_AUTO;
        itemReverse.customUI = YES;
        itemReverse.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemReverse.callbackBlock = ^(MHDeviceSettingCell *cell) {
            if (weakself.chooseMode) {
                weakself.chooseMode(AC_MODE_AUTO);
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        };
        
        [modeItems addObject:itemReverse];
        
        
        //送风
        MHDeviceSettingItem *itemFan = [[MHDeviceSettingItem alloc] init];
        itemFan.identifier = @"mydevice.gateway.sensor.acpartner.mode.fan";
        itemFan.type = MHDeviceSettingItemTypeCheckmark;
        itemFan.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.fan",@"plugin_gateway","送风");
        itemFan.hasAcIndicator = self.mode == AC_MODE_FAN;
        itemFan.customUI = YES;
        itemFan.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemFan.callbackBlock = ^(MHDeviceSettingCell *cell) {
            if (weakself.chooseMode) {
                weakself.chooseMode(AC_MODE_FAN);
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        };
        
        [modeItems addObject:itemFan];
        
        
        //除湿
        MHDeviceSettingItem *itemDry = [[MHDeviceSettingItem alloc] init];
        itemDry.identifier = @"mydevice.gateway.sensor.acpartner.mode.dry";
        itemDry.type = MHDeviceSettingItemTypeCheckmark;
        itemDry.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.dry",@"plugin_gateway","除湿");
        itemDry.hasAcIndicator = self.mode == AC_MODE_DRY;
        itemDry.customUI = YES;
        itemDry.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemDry.callbackBlock = ^(MHDeviceSettingCell *cell) {
            if (weakself.chooseMode) {
                weakself.chooseMode(AC_MODE_DRY);
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        };
        
        [modeItems addObject:itemDry];

    }
    
    groupModeChoice.items = modeItems;
    self.settingGroups = [NSMutableArray arrayWithObjects:groupModeChoice,nil];
    [self.settingTableView reloadData];
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
