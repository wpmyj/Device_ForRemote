//
//  MHGatewayDurationSettingViewController.m
//  MiHome
//
//  Created by guhao on 4/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayDurationSettingViewController.h"
#import "MHGatewayAlarmDurationPicker.h"
#import "MHLumiSettingCell.h"

@interface MHGatewayDurationSettingViewController ()

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSArray *timeArray;
@property (nonatomic, strong) MHDeviceSettingItem *oldItem;
@property (nonatomic, assign) NSInteger currentTime;

@property (nonatomic, strong) MHGatewayAlarmDurationPicker *durationPickerView;

@end

@implementation MHGatewayDurationSettingViewController

- (id)initWithGatewayDevice:(MHDeviceGateway *)gateway identifier:(NSString *)identifier currentTime:(NSInteger)currentTime
{
    self = [super init];
    if (self) {
        _gateway = gateway;
        _identifier = identifier;
        _currentTime = currentTime;
        if ([identifier isEqualToString:@"mydevice.gateway.setting.alarm.alarming.duration"]) {
            _timeArray = @[ @(4000000), @(600), @(60), @(30) ];
        }
        else if ([identifier isEqualToString:@"mydevice.gateway.setting.alarm.holdtime"]){
            _timeArray = @[ @(0), @(5), @(15), @(30), @(60) ];
        }
        //mydevice.gateway.setting.nightlight.holdtime
        else {
            _timeArray = @[ @(60), @(120), @(300), @(600) ];
        }
        self.isTabBarHidden = YES;
        self.controllerIdentifier = identifier;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)buildSubviews {
    [super buildSubviews];
    
    XM_WS(weakself);
    
    self.durationPickerView = [[MHGatewayAlarmDurationPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom",@"plugin_gateway","自定义") durationPicked:^(NSUInteger duration) {
        [weakself setDurationValue:@(duration) success:^(id v) {
            weakself.currentTime = duration;
            if (weakself.selectTime) {
                weakself.selectTime(@(weakself.currentTime));
            }
            [weakself dataConstruct];
        } failure:^(NSError *v) {
            
        }];
    }];
    
    
    [self dataConstruct];

}


- (void)dataConstruct {
    XM_WS(weakself);
    
    
    MHLuDeviceSettingGroup* groupSelHoldTime = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *selHoldTimeItems = [NSMutableArray arrayWithCapacity:1];
    groupSelHoldTime.title = nil;
    
    for (int i = 0; i < _timeArray.count; i++) {
        MHDeviceSettingItem *holdTimeItem0 = [[MHDeviceSettingItem alloc] init];
        NSString *identifier = [NSString stringWithFormat:@"%@.%@",_identifier, _timeArray[i]];
        holdTimeItem0.identifier = [NSString stringWithFormat:@"%@", _timeArray[i]];
        holdTimeItem0.type = MHDeviceSettingItemTypeCheckmark;
        holdTimeItem0.caption = NSLocalizedStringFromTable(identifier,@"plugin_gateway",nil);
        holdTimeItem0.hasAcIndicator = (self.currentTime == [_timeArray[i] integerValue]);
        holdTimeItem0.customUI = YES;
        holdTimeItem0.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        holdTimeItem0.callbackBlock = ^(MHDeviceSettingCell *cell) {
            if (cell.item.hasAcIndicator) {
                if (weakself.selectTime) {
                    weakself.selectTime(@(weakself.currentTime));
                }
            }
            if ([weakself.identifier isEqualToString:@"mydevice.gateway.setting.alarm.holdtime"]) {
                [weakself setGatewayvalue:weakself.timeArray[i] propId:ARMING_DELAY_INDEX success:^(id obj) {
                    weakself.oldItem.hasAcIndicator = NO;
                    cell.item.hasAcIndicator = YES;
                    weakself.oldItem = cell.item;
                    [weakself.settingTableView reloadData];
                    weakself.currentTime = [cell.item.identifier integerValue];
                    if (weakself.selectTime) {
                        weakself.selectTime(@(weakself.currentTime));
                    }
                } failure:^(NSError *v) {
                    
                }];
            }
            else if ([weakself.identifier isEqualToString:@"mydevice.gateway.setting.alarm.alarming.duration"]) {
                [weakself setDurationValue:weakself.timeArray[i] success:^(id v) {
                    weakself.oldItem.hasAcIndicator = NO;
                    cell.item.hasAcIndicator = YES;
                    weakself.oldItem = cell.item;
                    [weakself.settingTableView reloadData];
                    weakself.currentTime = [cell.item.identifier integerValue];
                    if (weakself.selectTime) {
                        weakself.selectTime(@(weakself.currentTime));
                    }
                } failure:^(NSError *v) {
                    
                }];
            }
            else {
                [weakself setGatewayvalue:weakself.timeArray[i] propId:CORRIDOR_ON_TIME_INDEX success:^(id obj) {
                    weakself.oldItem.hasAcIndicator = NO;
                    cell.item.hasAcIndicator = YES;
                    weakself.oldItem = cell.item;
                    [weakself.settingTableView reloadData];
                    weakself.currentTime = [cell.item.identifier integerValue];
                    if (weakself.selectTime) {
                        weakself.selectTime(@(weakself.currentTime));
                    }
                } failure:^(NSError *v) {
                    
                }];
            }
        };
        if (holdTimeItem0.hasAcIndicator) {
            self.oldItem = holdTimeItem0;
        }
        [selHoldTimeItems addObject:holdTimeItem0];
    }
    
    if ([self.identifier isEqualToString:@"mydevice.gateway.setting.alarm.alarming.duration"]) {
        MHLumiSettingCellItem *itemAddAC = [[MHLumiSettingCellItem alloc] init];
        itemAddAC.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
        itemAddAC.lumiType = MHLumiSettingItemTypeAccess;
        itemAddAC.hasAcIndicator = YES;
        itemAddAC.caption = NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom",@"plugin_gateway","自定义");
        if (self.currentTime < 60 && self.currentTime != 30) {
            itemAddAC.comment = [NSString stringWithFormat:@"%ld%@", self.currentTime, NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.second",@"plugin_gateway","秒")];
        }
        itemAddAC.customUI = YES;
        itemAddAC.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
        itemAddAC.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
            [weakself.durationPickerView setDuration:weakself.currentTime];
            [weakself.durationPickerView showInView:weakself.view.window];
        };
        [selHoldTimeItems addObject:itemAddAC];

    }
    
    groupSelHoldTime.items = selHoldTimeItems;
    self.settingGroups = @[groupSelHoldTime];
    [self.settingTableView reloadData];
}


#pragma mark - 延时警戒时间/延时关灯时间
- (void)setGatewayvalue:(id)value
                 propId:(Gateway_Prop_Id)pro_id
                success:(SucceedBlock)success
                failure:(FailedBlock)failure {
    [self.gateway setProperty:pro_id value:value success:^(id respObj) {
        [[MHTipsView shareInstance] hide];
        if(success)success(respObj);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
}


#pragma mark - 报警时长
- (void)setDurationValue:(id)value
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    
    [self.gateway setDeviceProp:ARMING_PRO_ALARMDURATION value:value success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
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
