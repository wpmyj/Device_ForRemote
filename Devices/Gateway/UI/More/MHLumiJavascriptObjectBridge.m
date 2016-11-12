//
//  MHLumiJavascriptObjectBridge.m
//  MiHome
//
//  Created by guhao on 3/14/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiJavascriptObjectBridge.h"
#import <SDWebImage/SDWebImageManager.h>
#import "MHLMShareListBar.h"
#import "MHShareListBar.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHOpenInMiHomeManager.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import <UIKit/UIKit.h>
#import "MHLumiAddSubDevicesListManager.h"
#import "MHLumiChooseLogoListManager.h"


@interface MHLumiJavascriptObjectBridge ()

@property (nonatomic, weak) JSContext* jsContext;

@end

@implementation MHLumiJavascriptObjectBridge
#pragma mark - MHLMShareJSObjectProtocol
- (void)shareUrlWithType:(SHAREPLATFORM)shareType
                   Title:(NSString *)title
             description:(NSString *)description
               thumbnail:(NSString *)thumbnailUrl
                     url:(NSString *)url {
    if (![[SDImageCache sharedImageCache] imageFromDiskCacheForKey:thumbnailUrl]) {
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
    }
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:thumbnailUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MHTipsView shareInstance] hide];
            switch (shareType) {
                case WXTIMELINE:
                {
                    if (![WXApi isWXAppInstalled])
                    {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"share.wechat.uninstall", @"plugin_gateway", "请先安装微信app再分享") duration:1.0f modal:NO];
                    }
                    else
                    {
                        [MHLMShareListBar shareToWXWithTitle:title description:description thumbnail:image url:url scene:WXSceneSession];
                    }
                }
                    break;
                case WXSESSION:
                {
                    if (![WXApi isWXAppInstalled])
                    {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"share.wechat.uninstall", @"plugin_gateway", "请先安装微信app再分享") duration:1.0f modal:NO];
                    }
                    else
                    {
                        
                        [MHLMShareListBar shareToWXWithTitle:title description:description thumbnail:image url:url scene:WXSceneTimeline];}
                }
                    break;
                case WBTIMELINE:
                {
                    if (![WeiboSDK isWeiboAppInstalled])
                    {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"share.weibo.uninstall", @"plugin_gateway", "请先安装微博app再分享") duration:1.0f modal:NO];
                    }
                    else
                    {
                        [MHLMShareListBar shareToWBWithTitle:title description:description thumbnail:image url:url];
                    }
                }
                    break;
                default:
                    break;
            }
            
        });
        
    }];
}

#pragma mark - 米聊号
- (NSString *)sendUserID {
    NSLog(@"测试数据22223333");
    NSLog(@"用户ID已经爆炸%@", [NSString stringWithFormat:@"%@", [MHPassportManager sharedSingleton].currentAccount.userId]);
    return [NSString stringWithFormat:@"%@", [MHPassportManager sharedSingleton].currentAccount.userId];
}
#pragma mark - 用户昵称
- (NSString *)sendNickName {
    return [NSString stringWithFormat:@"%@", [MHPassportManager sharedSingleton].currentAccount.nickName];
}
#pragma mark - 网关did
- (NSString *)sendGatewayDeviceID {
    return self.gatewayDevice.did;
}

- (NSString *)sendGatewayDeviceModel {
    return self.gatewayDevice.model;
}

- (NSString *)sendHumitureDeviceDid {
    return self.deviceDid;
}


- (NSString *)sendPlugDeviceDid {
    return  self.deviceDid;
}
#pragma mark - app版本
- (NSString *)sendAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    // app名称
    //    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //    // app build版本
    //    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"%@", app_Version);
    return [NSString stringWithFormat:@"iOS%@", app_Version];
}
#pragma mark - 应用内跳转到商城
- (void)goToMall {
    NSLog(@"天了噜走了吗");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *keyword = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"keyword%@",[MHPassportManager sharedSingleton].currentAccount.userId]];
        [[MHOpenInMiHomeManager sharedInstance] handleOpenURLString:[NSString stringWithFormat:@"mihome://searchstore?keyword=%@", keyword ? keyword : @"小米智能家庭套装"]];
    });
}
#pragma mark - 开始入网
- (void)startAddSubdevice:(NSString *)subdeviceModel andDeviceName:(NSString *)deviceName{
 
//    if (self.addSubDeviceCallBack) {
//        self.addSubDeviceCallBack(subdeviceModel, deviceName);
//    }
    
    [[MHLumiAddSubDevicesListManager sharedInstance] addSubdeviceWithSubDeviceType:subdeviceModel andDeviceName:deviceName];
    
}

#pragma mark - 首页/设备页换图标
- (void)sendImageID:(NSString *)imageID andImageName:(NSString *)imageName andImageUrls:(NSArray *)imageUrls {
    NSLog(@"图片的id%@", imageID);
    NSLog(@"图片的id%@", imageName);
    NSLog(@"图片地址%@", imageUrls);
    [[MHLumiChooseLogoListManager sharedInstance] updateLogoWithImageID:imageID andImageName:imageName andImageUrls:imageUrls];
    
}


#pragma mark - 设备did
- (NSString *)sendCurrentDeviceDid {
    return _deviceDid;
}
#pragma mark - 设备model
- (NSString *)sendCurrentDeviceModel {
    return _currentDevice.model;
}
#pragma mark - 分享结果的通知
- (void)getWxShareResultNotification:(NSNotification *)note {
    id obj = note.userInfo[@"MHNotificationKey_Share_Rsp"];
    NSLog(@"%@", note.userInfo[@"MHNotificationKey_Share_Rsp"]);
    JSValue *jsParamFunc = self.jsContext[@"shareResult"];
    [jsParamFunc callWithArguments:@[ obj ]];
    
}
- (void)getWbShareResultNotification:(NSNotification *)note {
    id obj = note.userInfo[@"MHNotificationKey_Share_Rsp"];
    NSLog(@"%@", note.userInfo[@"MHNotificationKey_Share_Rsp"]);
    JSValue *jsParamFunc = self.jsContext[@"shareResult"];
    [jsParamFunc callWithArguments:@[ obj ]];
}


#pragma mark - 初始化
- (id)initWithJSContext:(JSContext *)jsContext
{
    self = [super init];
    if (self) {
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWxShareResultNotification:) name:MHNotification_ShareToWx_Rsp object:nil];
        //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWbShareResultNotification:) name:MHNotification_ShareToWb_Rsp object:nil];
        _jsContext = jsContext;
    }
    return self;
}

- (void)dealloc {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:MHNotification_ShareToWx_Rsp object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:MHNotification_ShareToWb_Rsp object:nil];
}

@end
