//
//  MHGatewayAboutViewController.m
//  MiHome
//
//  Created by Lynn on 8/27/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayAboutViewController.h"
#import "MHGatewayWebViewController.h"
#import "MHLumiDreamPartnerDataManager.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHGatewayInfoViewController.h"
#import "MHGatewayProtocolViewController.h"
#define introductionURL @"http://static.home.mi.com/app/static/page/name/guide_page_lumi_gateway_v1.html"
#define tutorialURL @"http://www.lumiunited.com/nav/service/tutorial-mb.php"
#define kColdPlayCN         @"https://app-ui.aqara.cn/cool/cn/list.html"
#define kColdPlayEN         @"https://app-ui.aqara.cn/cool/en/list.html"

//#define coldPlay @"http://192.168.0.92:8080/html/cool/list.html"

@interface MHGatewayAboutViewController ()<MHGatewayInfoViewControllerDelegate>


@end

@implementation MHGatewayAboutViewController
{
    BOOL        _canShowVersion;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.about.title",@"plugin_gateway", @"");
    [self setTableview];
//    
//    UIView *hideBtn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//    hideBtn.backgroundColor = [UIColor clearColor];
//    hideBtn.center = self.view.center;
//    hideBtn.userInteractionEnabled = YES;
//    [self.view addSubview:hideBtn];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayTable:)];
    tap.numberOfTapsRequired = 5;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)dealloc {
    NSLog(@"ddddd");
}

- (void)displayTable:(id)sender {
    if (_canShowVersion){
        _canShowVersion = NO;
    }
    else {
        _canShowVersion = YES;
    }
    [self setTableview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTableview
{
    __weak typeof(self) weakSelf = self;
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
        
        MHDeviceSettingItem *item1 = [[MHDeviceSettingItem alloc] init];
        item1.identifier = @"mydevice.gateway.about.introducation";
        item1.type = MHDeviceSettingItemTypeDefault;
        item1.hasAcIndicator = YES;
        item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.about.introducation",@"plugin_gateway","套装介绍");
        item1.customUI = YES;
        item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item1.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakSelf gw_clickMethodCountWithStatType:@"introduction"];

            [weakSelf openWebVC:introductionURL identifier:@"mydevice.gateway.about.introducation"];
        };
        [items addObject:item1];
        
        MHDeviceSettingItem *item3 = [[MHDeviceSettingItem alloc] init];
        item3.identifier = @"bbs";
        item3.type = MHDeviceSettingItemTypeDefault;
        item3.hasAcIndicator = YES;
        item3.caption = NSLocalizedStringFromTable(@"mydevice.gateway.about.bbs",@"plugin_gateway","智能家庭套装论坛");
        item3.customUI = YES;
        item3.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item3.callbackBlock = ^(MHDeviceSettingCell *cell) {
            
            [weakSelf gw_clickMethodCountWithStatType:@"bbs"];
            [weakSelf openURL:@"http://bbs.xiaomi.cn/forum/detail/fid/363"];
        };
        [items addObject:item3];
        
        if (_canShowVersion){
            MHDeviceSettingItem *item4 = [[MHDeviceSettingItem alloc] init];
            item4.identifier = @"version";
            item4.type = MHDeviceSettingItemTypeDefault;
            item4.hasAcIndicator = NO ;
            item4.caption = [NSString stringWithFormat:@"套装版本:2.9.1, 主版本:%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
            item4.customUI = YES;
            item4.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
            item4.callbackBlock = ^(MHDeviceSettingCell *cell) {
                
            };
            [items addObject:item4];
            
            if([self.gatewayDevice.model isEqualToString:kGatewayModelV3]){
                MHDeviceSettingItem *protocolItem = [[MHDeviceSettingItem alloc] init];
                protocolItem.identifier = @"protocol";
                protocolItem.type = MHDeviceSettingItemTypeDefault;
                protocolItem.hasAcIndicator = YES;
                //TODO: 多语言
                protocolItem.caption = @"局域网通信协议";
                protocolItem.customUI = YES;
                protocolItem.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
                protocolItem.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    MHGatewayProtocolViewController *vc = [[MHGatewayProtocolViewController alloc] init];
                    vc.dataGetter = weakSelf.gatewayDevice;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                };
                [items addObject:protocolItem];
                
                MHDeviceSettingItem *gatewayInfoItem = [[MHDeviceSettingItem alloc] init];
                gatewayInfoItem.identifier = @"gatewayInfo";
                gatewayInfoItem.type = MHDeviceSettingItemTypeDefault;
                gatewayInfoItem.hasAcIndicator = YES;
                //TODO: 多语言
                gatewayInfoItem.caption = @"网关信息";
                gatewayInfoItem.customUI = YES;
                gatewayInfoItem.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
                gatewayInfoItem.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    MHGatewayInfoViewController *vc = [[MHGatewayInfoViewController alloc] init];
                    vc.gatewayInfoGetter = weakSelf.gatewayDevice;
                    vc.delegate = weakSelf;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                };
                [items addObject:gatewayInfoItem];
            }
        }
        
        MHDeviceSettingItem *item5 = [[MHDeviceSettingItem alloc] init];
        item5.identifier = @"mydevice.actionsheet.tutorial";
        item5.type = MHDeviceSettingItemTypeDefault;
        item5.hasAcIndicator = YES;
        item5.caption = NSLocalizedStringFromTable(@"mydevice.actionsheet.tutorial",@"plugin_gateway","玩法教程");
        item5.customUI = YES;
        item5.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item5.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakSelf gw_clickMethodCountWithStatType:@"tutorial"];
            [weakSelf openURL:tutorialURL];
            //            [weakSelf openWebVC:tutorialURL identifier:@"mydevice.actionsheet.tutorial"];
        };
        [items addObject:item5];

//
//        MHDeviceSettingItem *item6 = [[MHDeviceSettingItem alloc] init];
//        item6.identifier = @"mydevice.actionsheet.coldplay";
//        item6.type = MHDeviceSettingItemTypeDefault;
//        item6.hasAcIndicator = YES;
//        item6.caption = NSLocalizedStringFromTable(@"mydevice.actionsheet.coldplay", @"plugin_gateway", @"酷玩秘籍");
//        item6.customUI = YES;
//        item6.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
//        item6.callbackBlock = ^(MHDeviceSettingCell *cell) {
//            [weakSelf gw_clickMethodCountWithStatType:@"coldplay"];
//            NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
//            if ([currentLanguage hasPrefix:@"zh-Hans"]) {
//                [weakSelf openWebVC:kColdPlayCN identifier:@"mydevice.actionsheet.coldplay"];
//            }
//            else {
//                [weakSelf openWebVC:kColdPlayEN identifier:@"mydevice.actionsheet.coldplay"];
//            }
//        };
//        [items addObject:item6];
        group1.items = items;

    }
    
    self.settingGroups = [NSArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
}

-(void)openURL:(NSString *)urlstring
{
    NSURL *URL = [NSURL URLWithString:urlstring];
    [[UIApplication sharedApplication] openURL:URL];
}

- (void)openWebVC:(NSString *)strURL identifier:(NSString *)identifier {
    NSURL *URL = [NSURL URLWithString:strURL];
    MHGatewayWebViewController *webview = [[MHGatewayWebViewController alloc] initWithURL:URL];
    webview.controllerIdentifier = identifier;
    webview.hasShare = NO;
    NSString *descrp = NSLocalizedStringFromTable(identifier, @"plugin_gateway", nil);
    NSString *title = NSLocalizedStringFromTable(@"mydevice.gateway.about.title", @"plugin_gateway", @"关于 - 小米智能家庭套装");
    webview.title = descrp;
    [webview shareWithTitle:title description:descrp thumbnail:nil url:nil];
    webview.strOriginalURL = strURL;
    webview.isTabBarHidden = YES;
    //酷玩秘籍请求gid
//    if ([strURL isEqualToString:kColdPlayEN] || [strURL isEqualToString:kColdPlayCN]) {
        [[MHLumiDreamPartnerDataManager sharedInstance] fetchDreamPartnerDataSuccess:^(id obj) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *gid = obj[@"gid"];
                [[NSUserDefaults standardUserDefaults] setObject:gid forKey:[NSString stringWithFormat:@"keyword%@",[MHPassportManager sharedSingleton].currentAccount.userId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } andFailure:^(NSError *v) {
            
        }];
//    }
  
    [self.navigationController pushViewController:webview animated:YES];
}

#pragma mark - MHGatewayInfoViewControllerDelegate
- (void)gatewayInfoViewController:(MHGatewayInfoViewController *)viewController didTapEncryptionButton:(UIButton *)encryptionButton{
    MHGatewayProtocolViewController *vc = [[MHGatewayProtocolViewController alloc] init];
    vc.dataGetter = self.gatewayDevice;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
