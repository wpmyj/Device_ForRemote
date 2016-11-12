//
//  MHLumiHtmlHandleManager.h
//  MiHome
//
//  Created by guhao on 3/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewayBase.h"
#import "MHDeviceGatewayBaseService.h"

@interface MHLumiHtmlHandleTools : NSObject
//初始化单例
+ (id)sharedInstance;
//获取当前的视图控制器
- (UIViewController *)currentViewController;
//当前语言环境
- (NSString *)currentLanguage;
//当前语言是否为中文
- (BOOL)currentLanguageIsChinese;


@end
