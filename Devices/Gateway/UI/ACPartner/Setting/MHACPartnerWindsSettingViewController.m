//
//  MHACPartnerWindsSettingViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerWindsSettingViewController.h"

@interface MHACPartnerWindsSettingViewController ()

@property (nonatomic, assign) int winds;
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@end

@implementation MHACPartnerWindsSettingViewController

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self dataConstruct];
//    }
//    return self;
//}
//
//- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
//{
//    self = [super init];
//    if (self) {
//        self.isTabBarHidden = YES;
//        self.acpartner = acpartner;
//        [self dataConstruct];
//    }
//    return self;
//}

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner currentWinds:(int)winds
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        self.winds = winds;
        [self dataConstruct];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title =  NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速");

}

-(void)dataConstruct{
    
    XM_WS(weakself);
    MHLuDeviceSettingGroup* groupModeChoice = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *modeItems = [NSMutableArray arrayWithCapacity:1];
    groupModeChoice.items = modeItems;
    groupModeChoice.title = nil;
 
    
    MHDeviceSettingItem *itemForward = [[MHDeviceSettingItem alloc] init];
    itemForward.identifier = @"mydevice.gateway.sensor.acpartner.fanspeed.one";
    itemForward.type = MHDeviceSettingItemTypeCheckmark;
    itemForward.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.low",@"plugin_gateway","低速");
    itemForward.hasAcIndicator = self.winds == AC_WIND_SPEED_LOW;
    itemForward.customUI = YES;
    itemForward.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemForward.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (weakself.chooseWinds) {
            weakself.chooseWinds(AC_WIND_SPEED_LOW);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
        
    };
    [modeItems addObject:itemForward];

    
    MHDeviceSettingItem *itemReverse = [[MHDeviceSettingItem alloc] init];
    itemReverse.identifier = @"mydevice.gateway.sensor.acpartner.fanspeed.two";
    itemReverse.type = MHDeviceSettingItemTypeCheckmark;
    itemReverse.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.medium",@"plugin_gateway","中速");
    itemReverse.hasAcIndicator = self.winds == AC_WIND_SPEED_MEDIUM;
    itemReverse.customUI = YES;
    itemReverse.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemReverse.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (weakself.chooseWinds) {
            weakself.chooseWinds(AC_WIND_SPEED_MEDIUM);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
        
    };
    
    [modeItems addObject:itemReverse];
    
    
    MHDeviceSettingItem *itemThree = [[MHDeviceSettingItem alloc] init];
    itemThree.identifier = @"mydevice.gateway.sensor.acpartner.fanspeed.three";
    itemThree.type = MHDeviceSettingItemTypeCheckmark;
    itemThree.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.high",@"plugin_gateway","高速");
    itemThree.hasAcIndicator = self.winds == AC_WIND_SPEED_HIGH;
    itemThree.customUI = YES;
    itemThree.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemThree.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (weakself.chooseWinds) {
            weakself.chooseWinds(AC_WIND_SPEED_HIGH);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
        
    };
    
    [modeItems addObject:itemThree];
    
    
    MHDeviceSettingItem *itemAuto = [[MHDeviceSettingItem alloc] init];
    itemAuto.identifier = @"mydevice.gateway.sensor.acpartner.fanspeed.auto";
    itemAuto.type = MHDeviceSettingItemTypeCheckmark;
    itemAuto.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.auto",@"plugin_gateway","自动风速");
    itemAuto.hasAcIndicator = self.winds == AC_WIND_SPEED_AUTO;
    itemAuto.customUI = YES;
    itemAuto.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemAuto.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (weakself.chooseWinds) {
            weakself.chooseWinds(AC_WIND_SPEED_AUTO);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
        
    };
    
    [modeItems addObject:itemAuto];

    
    groupModeChoice.items = modeItems;
    self.settingGroups = [NSMutableArray arrayWithObjects:groupModeChoice,nil];
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
