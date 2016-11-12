//
//  MHLumiHtmlHandleManager.m
//  MiHome
//
//  Created by guhao on 3/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiHtmlHandleTools.h"
#import "MHGatewayWebViewController.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import "MHDeviceGateway.h"
#import "MHLumiChangeIconManager.h"
#import "MHLumiAddSubDevicesListManager.h"
#import "MHLumiLogGraphManager.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHRootViewControllerDelegate.h"

#define kADDSUBDEVICE_URL_HEAD @"http://app-webui.mi-ae.com.cn/sub-device/index"
#define kCHOOSELOGO_URL_HEAD   @"http://192.168.0.92:8088/icon/index"

@interface MHLumiHtmlHandleTools ()

@property (nonatomic, strong) MHDeviceGatewayBase *currentDevice;

@end

@implementation MHLumiHtmlHandleTools
+ (id)sharedInstance {
    static MHLumiHtmlHandleTools *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHLumiHtmlHandleTools alloc] init];
        }
    });
    return manager;
}

#pragma mark - 获取当前屏幕显示页面的viewcontroller
-(UIViewController*) findBestViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
        
    } else {
        
        // Unknown view controller type, return last child view controller
        return vc;
        
    }
    
}
//获取当前屏幕显示的viewcontroller
-(UIViewController*) currentViewController {
    // Find best view controller
    UIViewController* rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([rootController respondsToSelector:@selector(getTabBarController)] == YES){
        id<MHRootViewControllerDelegate>delegate = (id<MHRootViewControllerDelegate>)rootController;
        rootController = [delegate getTabBarController];
    }
    return [self findBestViewController:rootController];    
}

- (NSString *)currentLanguage {
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}

- (BOOL)currentLanguageIsChinese {
    BOOL isCN = YES;
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSLog(@"当前的语言环境%@", currentLanguage);
    if ([[currentLanguage lowercaseString] containsString:@"zh"]) {
        isCN = YES;
    }
    else {
        isCN = NO;
    }
    return isCN;
}




@end
