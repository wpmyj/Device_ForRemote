//
//  MHGatewayCubeViewController.m
//  MiHome
//
//  Created by guhao on 16/2/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCubeViewController.h"
#import "MHDeviceGatewaySensorCube.h"
#import "MHGatewaySensorViewController.h"
#import "MHGatewayWebViewController.h"
#import "MHGatewayCubeGuidePages.h"
#import "Appdelegate.h"
#import "MHLumiHtmlHandleTools.h"

#define kGuidePagesKey @"ShowGuidePages"
@interface MHGatewayCubeViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorCube *cubeDevice;
@property (nonatomic, assign) BOOL isShowGuidePages;
@end

@implementation MHGatewayCubeViewController {
    UIActionSheet *_actionSheet;
}

- (id)initWithDevice:(MHDevice *)device {
    if (self = [super initWithDevice:device]) {
        self.cubeDevice = (MHDeviceGatewaySensorCube *)device;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.cubeDevice.name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self isGuidePagesShown]) {
        [self setIsShowGuidePages:YES];
        _isShowGuidePages = YES;
        [self showGuide];
    }
}

#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    //mydevice.gateway.sensor.cube.actionDemo
    NSString* strActionDemo = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.actionDemo",@"plugin_gateway","动作演示");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    
     NSString* strShowMode = _cubeDevice.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    
    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    NSArray *titlesArray = @[ strActionDemo, strChangeTitle, strShowMode, strFeedback ];
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showPromptInView:self.view withHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
                //取消
                break;
            }

            case 1: {
                //动作演示
                [weakself showGuide];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetActionGuide"];
                break;
            }
            case 2: {
                //重命名
                [weakself deviceChangeName];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
                break;
            }
            case 3: {
                // 设置列表显示
                [weakself.cubeDevice setShowMode:(int)!weakself.cubeDevice.showMode success:^(id obj) {
                    
                } failure:^(NSError *v) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
                }];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
                break;
            }
                
            case 4: {
                //反馈
                [weakself onFeedback];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetFeedback"];
                break;
            }
            default:
                break;
        }
        //            case 6: {
        //                //常见问题
        //                [weakself openFAQ:[[weakself.deviceHt class] getFAQUrl]];
        //                break;
        //            }
        
    } withTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多") cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") destructiveButtonTitle:nil otherButtonTitlesArray:titlesArray];

    
}
#pragma mark - 引导页
-(void)showGuide {
    [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    MHGatewayCubeGuidePages *guidePage = [[MHGatewayCubeGuidePages alloc] initWithFrame:self.view.bounds];
    guidePage.isExitOnClickBg = NO;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:guidePage];    
}

//- (void)actionShow {
//    NSString *url = nil;
//    NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
//    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
//        url = kCubeMovieURLCN;
//    }
//    else {
//        url = kCubeMovieURLEN;
//    }
//    MHGatewayWebViewController* web = [[MHGatewayWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
//    web.isTabBarHidden = YES;
//    web.hasShare = NO;
//    web.controllerIdentifier = @"cubeActionShow";
//    web.strOriginalURL = url;
//    [self.navigationController pushViewController:web animated:YES];
//}

-(BOOL)isGuidePagesShown {
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     kGuidePagesKey,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(flag){
        return [flag boolValue];
    }
    return NO;
}

- (void)setIsShowGuidePages:(BOOL)isShowGuidePages {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* key = [NSString stringWithFormat:@"%@_%@",
                         kGuidePagesKey,
                         [MHPassportManager sharedSingleton].currentAccount.userId];
        NSNumber* flag = [NSNumber numberWithBool:isShowGuidePages];
        [defaults setObject:flag forKey:key];
        [defaults synchronize];
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
