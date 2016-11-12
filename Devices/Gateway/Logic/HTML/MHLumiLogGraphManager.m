//
//  MHLumiLogGraphTool.m
//  MiHome
//
//  Created by guhao on 3/21/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiLogGraphManager.h"
#import "MHLumiHtmlHandleTools.h"

#define kNatgas_Url_Cn @"http://192.168.0.92:8088/density/natgas/cn"
#define kNatgas_Url_En @"http://192.168.0.92:8088/density/natgas/en"


#define kSmoke_Url_Cn @"http://192.168.0.92:8088/density/smoke/cn"
#define kSmoke_Url_En @"http://192.168.0.92:8088/density/smoke/en"


#define HumitureLogWebPageURLCN           @"https://app-ui.aqara.cn/temperature/cn/index"
#define HumitureLogWebPageURLEN           @"https://app-ui.aqara.cn/temperature/en/index"

#define kPLUG_GRAPH_URL         @"https://app-ui.aqara.cn/power/cn/index?isBlue=true"
#define kPLUG_GRAPH_URL_EN      @"https://app-ui.aqara.cn/power/en/index?isBlue=true"

@interface MHLumiLogGraphManager ()

@property (nonatomic, strong) MHDeviceGatewayBase *currentDevice;


@end

@implementation MHLumiLogGraphManager
+ (id)sharedInstance {
    static MHLumiLogGraphManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHLumiLogGraphManager alloc] init];
        }
    });
    return manager;
}



- (void)getLogListGraphWithDeviceDid:(NSString *)did
                       andDeviceType:(GraphDeviceType)deviceType
                              andURL:(NSString *)url
                            andTitle:(NSString *)title
               andSegeViewController:(UIViewController *)segeViewController {
    NSString *newUrl = nil;
    switch (deviceType) {
        case MHGATEWAYGRAPH_PLUG:
        case MHGATEWAYGRAPH_ACPARTNER:
            newUrl = [[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese] ? kPLUG_GRAPH_URL : kPLUG_GRAPH_URL_EN;
            break;
        case MHGATEWAYGRAPH_HUMITURE:
            newUrl = [[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese] ? HumitureLogWebPageURLCN : HumitureLogWebPageURLEN;
            break;
        case MHGATEWAYGRAPH_NATGAS:
            newUrl = [[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese] ? kNatgas_Url_Cn : kNatgas_Url_En;
            break;
        case MHGATEWAYGRAPH_SMOKE:
            newUrl = [[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese] ? kSmoke_Url_Cn : kSmoke_Url_En;
            break;
            
        default:
            break;
    }
    NSURL *URL = [NSURL URLWithString:newUrl];
    MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:URL];
    web.controllerIdentifier = title;
    web.deviceDid = did;
    web.deviceType = deviceType;
    web.graphFlag = YES;
    web.strOriginalURL = newUrl;
    web.isTabBarHidden = YES;
    web.title = title;
    [segeViewController.navigationController pushViewController:web animated:YES];

}
@end
