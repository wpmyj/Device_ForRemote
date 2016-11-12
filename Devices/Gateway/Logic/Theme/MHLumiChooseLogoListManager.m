//
//  MHLumiChooseLogoTool.m
//  MiHome
//
//  Created by guhao on 3/21/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiChooseLogoListManager.h"
#import "MHGatewayWebViewController.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHLumiChangeIconManager.h"
#import <AFNetworking/AFNetworking.h>

#define kCHOOSELOGO_URL_HEAD   @"https://app-ui.aqara.cn/icon/index"
#define kLOGOFLAG_URL_HEAD     @"http://app-ui.aqara.cn/icon/count"
@interface MHLumiChooseLogoListManager ()


@end

@implementation MHLumiChooseLogoListManager

+ (id)sharedInstance {
    static MHLumiChooseLogoListManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHLumiChooseLogoListManager alloc] init];
        }
    });
    return manager;
}

#pragma mark - 选择图标回调
- (void)updateLogoWithImageID:(NSString *)imageID
                 andImageName:(NSString *)imageName
                 andImageUrls:(NSArray *)imageUrls {
    XM_WS(weakself);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting", @"plugin_gateway", nil) modal:YES];

        //下载图片
        [[MHLumiChangeIconManager sharedInstance] deviceIconByService:weakself.currentService iconId:imageID iconUrlArray:imageUrls withCompletionHandler:^(id  _Nullable result, NSError * _Nullable error) {
            if (error) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", nil)
                                                  duration:1.5f
                                                     modal:YES];
            }
            else {
                //下载成功,开始设置图片
                [[MHLumiChangeIconManager sharedInstance] setDeviceIconWith:weakself.currentService withIconId:imageID completionHandler:^(id result, NSError *error) {
                    if (error) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", nil)
                                                          duration:1.5f
                                                             modal:YES];
                    }
                    else {
                        if(weakself.setIconName) weakself.setIconName(imageName, imageID);
                        weakself.currentService.serviceIconId = imageID;
                        if(weakself.setIconSuccessed) weakself.setIconSuccessed(weakself.currentService);
                        [[MHTipsView shareInstance] hide];
                        if (!self.isAddSubDevice) {
                            AppDelegate *app = [UIApplication sharedApplication].delegate;
                            [app.currentViewController.navigationController popViewControllerAnimated:YES];
                        }
                    }
                }];
            }
            
        }];
    });
}

- (void)chooseLogoWithSevice:(MHDeviceGatewayBaseService *)service
                      iconID:(NSString *)iconID
             titleIdentifier:(NSString *)identifier
          segeViewController:(UIViewController *)segeViewController {
    _currentService = service;
    NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
    NSString *strUrl = [NSString stringWithFormat:@"%@?language=%@&deviceModel=%@&iconId=%@", kCHOOSELOGO_URL_HEAD, currentLanguage, service.serviceParentModel, iconID];
    NSURL *url = [NSURL URLWithString:strUrl];
    MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:url];
    web.controllerIdentifier = identifier;
    web.strOriginalURL = strUrl;
    web.isTabBarHidden = YES;
    web.hasShare = NO;
    web.title = NSLocalizedStringFromTable(identifier,@"plugin_gateway", nil);
    dispatch_async(dispatch_get_main_queue(), ^{
        [segeViewController.navigationController pushViewController:web animated:YES];
    });

}

- (BOOL)isShowLogoListWithandDeviceModel:(NSString *)model finish:(FinishCallBack)finish{
    __block BOOL logoFlag = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", kISSHOWLOGOLISTKEY, model]] boolValue];
    if (logoFlag) {
        return logoFlag;
    }
    [[AFHTTPSessionManager manager] GET:kLOGOFLAG_URL_HEAD parameters:@{ @"deviceModel" : model } success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            logoFlag = [responseObject[@"flag"] boolValue];
            [[NSUserDefaults standardUserDefaults] setObject:@(logoFlag) forKey:[NSString stringWithFormat:@"%@%@", kISSHOWLOGOLISTKEY, model]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if(finish)finish(@(logoFlag), nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(finish)finish(@(logoFlag), error);
    }];
    return logoFlag;
}

@end
