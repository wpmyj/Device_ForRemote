//
//  MHGatewayWebViewController.h
//  MiHome
//
//  Created by Lynn on 9/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MHDeviceGateway.h"
#import "MHDeviceGatewaySensorHumiture.h"
#import "MHDeviceGatewaySensorPlug.h"
#import "MHLumiHtmlHandleTools.h"

typedef NS_ENUM(NSInteger, Humiture) {
    LandscapeLeft,
    LandscapeRight,
};
typedef NS_ENUM(NSInteger, GraphDeviceType) {
    MHGATEWAYGRAPH_PLUG = 1,
    MHGATEWAYGRAPH_HUMITURE,
    MHGATEWAYGRAPH_NATGAS,
    MHGATEWAYGRAPH_SMOKE,
    MHGATEWAYGRAPH_ACPARTNER,
};

#define kNOTFOUNDDEVICE @"http://m.mi.com/1/#/product/list?id=151"

#define kMotionBuyingLinksKey @"sensor_motion_buyingLinks"
#define kMagnetBuyingLinksKey @"sensor_magnet_buyingLinks"

/*
 "
 
 */
#define kNewUserEN @"https://app-ui.aqara.cn/guide/en/index.html"
#define kNewUserCN @"https://app-ui.aqara.cn/guide/cn/index.html"



@interface MHGatewayWebViewController : MHLuWebViewController 

@property (nonatomic, strong) MHDeviceGateway *gatewayDevice;
@property (nonatomic, strong) MHDeviceGatewayBase *currentDevice;
@property (nonatomic, strong) NSString *deviceDid;
@property (nonatomic, assign) NSInteger deviceType;
@property (nonatomic, assign) BOOL graphFlag;

@property (nonatomic, assign) BOOL hasShare;//是否需要分享按钮
@property (nonatomic, weak) JSContext* jsContext;
@property (nonatomic, copy) NSString* strOriginalURL;
@property (nonatomic, copy) NSString* strOldURL;


/**
 *  分享链接
 *
 *  @param title       标题
 *  @param description 内容描述
 *  @param shareImage  内容缩略图
 *  @param shareUrl    分享url, 传入nil默认分享当前web的url
 
 */
- (void)shareWithTitle:(NSString *)title
           description:(NSString *)description
             thumbnail:(UIImage *)thumbnail
                   url:(NSString *)url;

+ (MHGatewayWebViewController *)openWebVC:(NSString *)strURL identifier:(NSString *)identifier share:(BOOL)isShare;

@end
