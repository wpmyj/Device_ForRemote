//
//  MHGatewayTempAndHumidityViewController.m
//  MiHome
//
//  Created by guhao on 15/12/31.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHDeviceGatewaySensorHumiture.h"
#import <UIKit/UIKit.h>
#import "MHGatewayHtPushViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHGatewayHumitureCell.h"
#import "MHGatewayHumitureRefreshView.h"
#import "MHDeviceGatewaySensorLoopData.h"
#import "MHGatewaySceneManager.h"
#import "MHDataScene.h"
#import "MHGatewayHumitureIntervalViewController.h"
#import "MHLumiLogGraphManager.h"
#import "MHGatewayNamingSpeedViewController.h"
#import "MHGatewayHTUnusualeView.h"

#define kSELECTED_CITY_DATA_KEY [NSString stringWithFormat:@"lumi_ht_%@_%@_commenCitys", self.deviceHt.did, [MHPassportManager sharedSingleton].currentAccount.userId]
#define kHeaderViewHeight 467 * ScaleHeight
#define kFooterViewHeight 200 * ScaleHeight


#define kColdLevel 18.0f
#define kWarmLevel 27.0f


@interface MHGatewayTempAndHumidityViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MHGatewayHumitureRefreshViewDelegate>
@property (nonatomic, strong) MHDeviceGatewaySensorHumiture *deviceHt;
@property (nonatomic, strong) MHGatewayHumitureRefreshView *refreshView;
@property (nonatomic, strong) MHGatewayHTUnusualeView *unusualView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) NSInteger errorTips;

@property (nonatomic, assign) float temperature;
@property (nonatomic, assign) float humidity;

@end

@implementation MHGatewayTempAndHumidityViewController {
    UIActionSheet *_actionSheet;
}

-(id)initWithDevice:(MHDevice *)device {
    if(self = [super initWithDevice:device]) {
        self.deviceHt = (MHDeviceGatewaySensorHumiture*)device;
    }
    return self;
}

- (BOOL)isNeedBackButton{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.isTabBarHidden=YES;
    self.isNavBarTranslucent = YES;
    self.title = self.deviceHt.name;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.deviceHt readStatus];
//    [[MHGatewaySceneManager sharedInstance] fetchSceneListWithDevice:self.deviceHt stid:@"21" andSuccess:^(id obj) {
//        NSLog(@"%@",obj);
//        /*
//         {
//             code = 0;
//             message = ok;
//             result =     {
//                 0 =         {
//                     authed =             (
//                         "lumi.158d0000f708e7"
//                     );
//                     "home_id" = 0;
//                     identify = "";
//                     name = "温湿度传感器消息通知";
//                     setting =             {
//                         "enable_humiture" = 1;
//                     };
//                     "st_id" = 21;
//                     uid = 79789538;
//                     "us_id" = 8357753;
//                 };
//             };
//         }
//         */
//    } failure:^(NSError *v) {
//        
//    }];
    XM_WS(weakself);
    [self.deviceHt getHTProp:LUMI_HUMITURE_TEMP_PROP success:^(id v) {
        [weakself.tableView reloadData];

    } failure:^(NSError *v) {
        
    }];
    
    [self.deviceHt getHTProp:LUMI_HUMITURE_HUMIDITY_PROP success:^(id v) {
        [weakself.tableView reloadData];

    } failure:^(NSError *v) {
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
        
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.deviceHt saveStatus];
}


- (void)buildSubviews {
    [super buildSubviews];
    //tableview背景图片
    self.backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT)];
    [self.view addSubview:self.backGroundImageView];
    
    
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setShowsVerticalScrollIndicator:NO];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [self.tableView registerClass:[MHGatewayHumitureCell class] forCellReuseIdentifier:@"MHGatewayHumitureCell"];
    self.refreshView = [[MHGatewayHumitureRefreshView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    self.refreshView.delegate = self;
    [_tableView addSubview:self.refreshView];
    
    _unusualView = [[MHGatewayHTUnusualeView alloc] initWithFrame:CGRectMake(0, 64, WIN_WIDTH, 48)];
    [self.view addSubview:_unusualView];
    
    
   
}



#pragma mark - UITableViewDelegate&DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return WIN_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XM_WS(weakself);
    MHGatewayHumitureCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MHGatewayHumitureCell"];
    cell.cozyClickCallBack = ^(){
        [weakself cozyList];
    };
    cell.loglistClickCallBack = ^(){
        [weakself graphLogList];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.temperature = self.deviceHt.temperature;
    if(self.deviceHt.humidity < 0) cell.humidity = 0.f;
    else if (self.deviceHt.humidity > 100) cell.humidity = 100.f;
    else cell.humidity = self.deviceHt.humidity;
    
    [cell refreshUI];
    [cell layoutIfNeeded];
    float currentTemperature = cell.temperature;
    //设置背景色
    if (currentTemperature < kColdLevel) {
        _backGroundImageView.image = [UIImage imageNamed:@"lumi_ht_cold_bg"];
    }
    else if(currentTemperature >= kColdLevel && currentTemperature <= kWarmLevel) {
        _backGroundImageView.image = [UIImage imageNamed:@"lumi_ht_warm_bg"];
    }
    else {
        _backGroundImageView.image = [UIImage imageNamed:@"lumi_ht_hot_bg"];
    }
    if (!cell.humidity) {
        _backGroundImageView.image = [UIImage imageNamed:@"lumi_ht_warm_bg"];
        [self.unusualView updateTipsText:Network_INDEX];
        self.unusualView.hidden = NO;
    }
    else {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"unusuale_ht_%@_type%ld", self.deviceHt.did, self.unusualView.type]] boolValue]) {
            [self.unusualView updateTipsText:Environment_INDEX];
            if (self.deviceHt.temperature > 60 || self.deviceHt.temperature < -20) {
                self.unusualView.hidden = NO;
            }
            else {
                self.unusualView.hidden = YES;
            }
        }
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0) {
        _backGroundImageView.frame = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT - offsetY);
    }
    else if(offsetY > 0) {
        //上拉效果不理想,图片变形从上开始,试试调整图片模式
        _backGroundImageView.frame = CGRectMake(0, -offsetY, WIN_WIDTH, WIN_HEIGHT + offsetY);
    }
    [self.refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _backGroundImageView.frame = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)beginRefresh {
    self.isLoading = YES;
    [self updateData];
}

- (void)endRefresh {
    self.isLoading = NO;
    [self.refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(MHGatewayHumitureRefreshView *)view {
    [self beginRefresh];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(MHGatewayHumitureRefreshView *)view {
    return self.isLoading;
}

-(void)updateData{
    NSMutableArray* params=[[NSMutableArray alloc] init];
    [params addObject:LUMI_HUMITURE_TEMP_PROP];
    [params addObject:LUMI_HUMITURE_HUMIDITY_PROP];
    XM_WS(weakself);
    if(self.deviceHt){
        [self.deviceHt getDeviceProp:params success:^(id result){
            NSLog(@"温湿度请求结果%@", result);
                [weakself endRefresh];
                [weakself.tableView reloadData];
        } failure:^(id error){
            [weakself.tableView reloadData];
            if (weakself.isLoading) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.5f modal:YES];
            }
            [weakself endRefresh];
        }];
    }
    
}

#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString *strScene = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    NSString *strGraph = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.Trend",@"plugin_gateway","温湿度历史趋势");
    NSString *strPush = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.IndoorEnvironmentReminder",@"plugin_gateway","环境提醒");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","重命名");
    
    NSString* strShowMode = _deviceHt.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");

    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");

    NSArray *titlesArray = @[ strScene, strGraph, strPush, strChangeTitle, strShowMode, strFAQ, strFeedback ];

    XM_WS(weakself);
    [[MHPromptKit shareInstance] showPromptInView:self.view withHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
                //取消
                break;
            }
            case 1: {
                //自动化
                [weakself onAddScene];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetAddScene"];
                break;
            }
            case 2: {
                //温湿度历史
                [weakself graphLogList];
                
                break;
            }
            case 3: {
                //室内环境提醒
                [weakself remindIndoorEnvironment];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetEnvironment"];
                break;
            }
            case 4: {
                //修改设备名称
                [weakself deviceChangeName];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
                break;
            }
            case 5: {
                // 设置列表显示
                [weakself.deviceHt setShowMode:(int)!weakself.deviceHt.showMode success:^(id obj) {
                    
                } failure:^(NSError *v) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
                }];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
                break;
            }
            case 6: {
                //常见问题
                [weakself openFAQ:[[weakself.deviceHt class] getFAQUrl]];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetFAQ"];
                break;
            }
            case 7: {
                //反馈
                [weakself onFeedback];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetFeedback"];
                break;
            }
            default:
                break;
        }
       

    } withTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多") cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") destructiveButtonTitle:nil otherButtonTitlesArray:titlesArray];
    
}


-(void)onAddScene {
    MHGatewaySensorViewController *sceneVC = [[MHGatewaySensorViewController alloc] initWithDevice:self.deviceHt];
    sceneVC.isHasMore = NO;
    sceneVC.isHasShare = NO;
    [self.navigationController pushViewController:sceneVC animated:YES];
}

- (void)remindIndoorEnvironment {
    MHGatewayHtPushViewController *pushVC = [[MHGatewayHtPushViewController alloc] initWithDevice:self.deviceHt];
    [self.navigationController pushViewController:pushVC animated:YES];
}



#pragma mark - 图形日志
- (void)graphLogList {
    [[MHLumiLogGraphManager sharedInstance] getLogListGraphWithDeviceDid:self.deviceHt.did andDeviceType:MHGATEWAYGRAPH_HUMITURE andURL:nil andTitle:self.deviceHt.name andSegeViewController:self];
    [self gw_clickMethodCountWithStatType:@"actionSheetGraphLog"];
}

- (void)cozyList {
    MHLuViewController *cozyVC = [[MHGatewayHumitureIntervalViewController alloc] initWithDevice:self.deviceHt];
    cozyVC.title = self.deviceHt.name;
    [self.navigationController pushViewController:cozyVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openH&TCozyPage"];

//    MHGatewayNamingSpeedViewController *test = [[MHGatewayNamingSpeedViewController alloc] initWithSubDevice:self.deviceHt gatewayDevice:nil shareIdentifier:NO serviceIndex:0];
//    [self.navigationController pushViewController:test animated:YES];

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
