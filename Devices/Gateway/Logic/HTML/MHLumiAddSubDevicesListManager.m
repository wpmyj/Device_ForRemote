//
//  MHLumiAddSubDevicesTool.m
//  MiHome
//
//  Created by guhao on 3/21/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiAddSubDevicesListManager.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import "MHGatewayWebViewController.h"

#define kADDSUBDEVICE_URL_HEAD      @"https://app-ui.aqara.cn/sub-device/index"

@interface MHLumiAddSubDevicesListManager ()

@property (nonatomic, strong) MHDeviceGatewayBase *currentDevice;

@end

@implementation MHLumiAddSubDevicesListManager
+ (id)sharedInstance {
    static MHLumiAddSubDevicesListManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHLumiAddSubDevicesListManager alloc] init];
        }
    });
    return manager;
}

#pragma mark - addSubDeviceList
- (void)chooseAddSubDeviceListWithGatewayDevice:(MHDeviceGatewayBase *)gatewayDevice andTitleIdentifier:(NSString *)identifier andSegeViewController:(UIViewController *)segeViewController{
     NSString *userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    _currentDevice = gatewayDevice;
    NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
    NSString *strUrl = [NSString stringWithFormat:@"%@?language=%@&gatewayModel=%@&userID=%@", kADDSUBDEVICE_URL_HEAD, currentLanguage, gatewayDevice.model, userID];
    NSURL *url = [NSURL URLWithString:strUrl];
    MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:url];
    web.controllerIdentifier = identifier;
    web.strOriginalURL = strUrl;
    web.gatewayDevice = (MHDeviceGateway *)gatewayDevice;
    web.isTabBarHidden = YES;
    web.title = NSLocalizedStringFromTable(identifier, @"plugin_gateway","选择要连接的设备");
    [segeViewController.navigationController pushViewController:web animated:YES];
}

#pragma mark - addSubDevice
- (void)addSubdeviceWithSubDeviceType:(NSString *)deviceType andDeviceName:(NSString *)deviceName {
    XM_WS(weakself);
    dispatch_async(dispatch_get_main_queue(), ^{
        MHGatewayAddSubDeviceViewController *addSubDevicesVC = [[MHGatewayAddSubDeviceViewController alloc] initWithGateway:(MHDeviceGateway *)weakself.currentDevice andDeviceModel:deviceType];
        addSubDevicesVC.controllerIdentifier = deviceType;
        addSubDevicesVC.title = deviceName;
        [[[MHLumiHtmlHandleTools sharedInstance] currentViewController].navigationController pushViewController:addSubDevicesVC animated:YES];
    });
    
}
@end
