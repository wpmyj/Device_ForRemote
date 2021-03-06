//
//  MHLuDeviceViewControllerBase.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuDeviceViewControllerBase.h"
#import "MHDeviceGateway.h"
#import "MHGatewayWebViewController.h"

@implementation MHLuDeviceViewControllerBase

#pragma mark - 统计点击事件
-(void)gw_clickMethodCountWithStatType:(NSString *)statType{
    
    __block NSString *path = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            path = NSStringFromClass([obj class]);
        }
        else {
            path = [NSString stringWithFormat:@"%@_%@", path, NSStringFromClass([obj class])];
        }
    }];
        
    NSString *complete = [NSString stringWithFormat:@"page: %@ path: %@ , indentify: %@", NSStringFromClass(self.class), path, self.controllerIdentifier ];
    
    NSLog(@"路径分析%@", complete);

    //statType，统计名；value，次数值
    [[MHStatReportManager shareInstance] appendEventStatType:statType value:@(1) extra:complete appid:@"lumi"];
    NSLog(@"页面＝%@ ， 事件＝%@",NSStringFromClass(self.class), statType);
}

- (void)openFAQ:(NSString *)url {
    NSURL *URL = [NSURL URLWithString:url];
    MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:URL];
    web.hasShare = NO;
//    NSString *descrp = NSLocalizedStringFromTable(identifier, @"plugin_gateway", nil);
    NSString *title = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ", @"plugin_gateway", @"常见问题");
    web.title = title;
    web.strOriginalURL = url;
    web.isTabBarHidden = YES;
    web.controllerIdentifier = @"mydevice.gateway.about.freFAQ";
    [self.navigationController pushViewController:web animated:YES];
}

@end
