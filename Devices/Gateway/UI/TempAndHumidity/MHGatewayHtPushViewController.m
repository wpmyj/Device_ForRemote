//
//  MHGatewayHtPushViewController.m
//  MiHome
//
//  Created by guhao on 15/12/18.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayHtPushViewController.h"
#import "MHDeviceGatewaySensorHumiture.h"
#import "MHGatewaySceneManager.h"
#import "MHDataScene.h"

@interface MHGatewayHtPushViewController ()

@property (nonatomic, strong) NSMutableArray *humiturePushItems;
@property (nonatomic, strong) MHDeviceGatewaySensorHumiture *deviceHt;

@property (nonatomic, strong) MHGatewaySceneManager *sceneManager;

@end

@implementation MHGatewayHtPushViewController

- (instancetype)initWithDevice:(MHDevice *)device
{
    self = [super init];
    if (self) {
        _deviceHt = (MHDeviceGatewaySensorHumiture *)device;
        _sceneManager = [[MHGatewaySceneManager alloc] initWithManagerIdentify:@"humiturePush"];
        self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.IndoorEnvironmentReminder",@"plugin_gateway","室内环境提醒");
        [self dataConstruct];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updatePushSettingItems];
}

-(void)dataConstruct{
    XM_WS(weakself);
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    {
        _humiturePushItems = [[NSMutableArray alloc] init];
        
        MHDeviceSettingItem *itemHimuturePush = [[MHDeviceSettingItem alloc] init];
        itemHimuturePush.identifier = @"itemHimuturePush";
        itemHimuturePush.type = MHDeviceSettingItemTypeSwitch;
        itemHimuturePush.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.IndoorEnvironmentReminder",@"plugin_gateway","室内环境提醒");
        itemHimuturePush.comment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.SendMessage",@"plugin_gateway","室内环境提醒");//
        itemHimuturePush.customUI = YES;
        itemHimuturePush.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemHimuturePush.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself gw_clickMethodCountWithStatType:@"itemHimuturePush"];
            cell.item.isOn = !cell.item.isOn;
            /*"{\"setting\":{\"enable_humiture\":\"1\"}," +"\"authed\":[\"@@\"],\"name\":\"温湿度传感器消息通知\"," + "\"st_id\":21,\"us_id\":0,\"sr_id\":-1}"
             //         */

            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            NSString *uid = [MHPassportManager sharedSingleton].currentAccount.userId;
            NSString *did = weakself.deviceHt.did;
            [params setObject:@"21" forKey:@"st_id"];
            [params setObject:@"-1" forKey:@"sr_id"];
            [params setObject:@[ did ] forKey:@"authed"];
            [params setObject:uid forKey:@"uid"];
            [params setObject:@"0" forKey:@"us_id"];
            [params setObject:@{ @"enable_humiture":@"1" } forKey:@"setting"];
            [params setObject:@"温湿度传感器消息通知" forKey:@"name"];
            if (!cell.item.isOn) {
                [weakself.sceneManager saveSceneEditWithParms:params andSuccess:^(id respObj) {
                    NSLog(@"%@", respObj);
                    [cell finish];
                } andfailure:^(id v) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                    cell.item.isOn = !cell.item.isOn;
                    [cell fillWithItem:cell.item];
                    [cell finish];
                }];
            }
            else {
                [weakself.sceneManager fetchSceneListWithDevice:self.deviceHt stid:@"21" andSuccess:^(id obj) {
                    NSLog(@"%@", obj);
                    for (MHDataScene *scene in obj) {
                        [weakself.sceneManager deleteSceneWithUsid:scene.usId andSuccess:^(id v) {
                            [cell finish];
                        } andFailure:^(NSError *v) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];

                    }
                } failure:^(NSError *v) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                    cell.item.isOn = !cell.item.isOn;
                    [cell fillWithItem:cell.item];
                    [cell finish];

                }];
            }
        };
        [_humiturePushItems addObject:itemHimuturePush];
        
        group1.items = _humiturePushItems;
    }
    
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
}

- (void)updatePushSettingItems {
    __block MHDeviceSettingItem *itemHimuturePush = [self itemWithIdentifier:@"itemHimuturePush"];
    XM_WS(weakself);
    [self.sceneManager fetchSceneListWithDevice:self.deviceHt stid:@"21" andSuccess:^(id obj) {
        itemHimuturePush.isOn = [obj count] ? YES : NO;
        [weakself reloadItemAtIndex:[weakself indexOfItemWithIdentifier:@"itemHimuturePush"] atSection:0];
    } failure:^(NSError *v) {
        
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
