//
//  MHGatewayLogViewController.m
//  MiHome
//
//  Created by Lynn on 9/30/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayLogViewController.h"
#import "MHTableViewControllerInternal.h"
#import "MHDeviceGateway.h"
#import "MHGatewayLogCell.h"

@interface MHGatewayLogViewController () <MHTableViewControllerInternalDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) MHTableViewControllerInternal* tvcInternal;
@property (nonatomic, strong) MHDataListManagerBase* dataManager;
@property (nonatomic, strong) MHDeviceGatewayBase *sensor;
@end

@implementation MHGatewayLogViewController
{
    UIView *                _footerView;
    UIButton*               _btnDeleteLogs;
    UILabel*                _labelDeleteLogs;
    id                      _observer;
    
    CGFloat                 _lastOffsizeY;
    BOOL                    _stopGetMore;
    
    NSMutableArray *        _cameraList;
}
@synthesize dataManager = _dataManager;

- (id)initWithDevice:(MHDevice *)device {
    if (self = [super init]) {
        _sensor = (MHDeviceGatewayBase* )device;
        self.sensor = _sensor;
        if ([_sensor isKindOfClass:[MHDeviceGateway class]]) {
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
        }
        self.tvcInternal = [[MHTableViewControllerInternal alloc] initWithStyle:UITableViewStylePlain];
        self.tvcInternal.cellClass = [MHGatewayLogCell class];
        self.tvcInternal.delegate = self;
        self.dataManager = _sensor.logManager;
        self.tvcInternal.dataSource = [self.dataManager getDataList];

    }
    return self;
}

- (void)setDataManager:(MHDataListManagerBase *)dataManager {
    if ([dataManager isEqual:_dataManager]) {
        return;
    }
    
    _dataManager = dataManager;
    self.tvcInternal.dataSource = [dataManager getDataList];
    
    // 注册UIUpdateNotification
    NSString* notifName = [_dataManager notificationNameForUIUpdate];
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    if (_observer) {
        [notifCenter removeObserver:_observer];
        _observer = nil;
    }
    
    __weak typeof(self) weakself = self;
    _observer = [notifCenter addObserverForName:notifName
                                         object:nil
                                          queue:[NSOperationQueue mainQueue]
                                     usingBlock:^(NSNotification *note) {
                                         weakself.tvcInternal.delegate = weakself;
                                         weakself.tvcInternal.dataSource = [dataManager getDataList];
                                         [weakself.tvcInternal stopRefreshAndReload];
                                         [weakself onGetLatestLogSucceed];
                                         [weakself onDataSourceUpdated];
                                     }];
}

- (void)dealloc
{
    if (_observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self fetchLoglist];
}

-(void)buildSubviews{
    [super buildSubviews];
    
    //Footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 65, CGRectGetWidth(self.view.bounds), 65)];
    _footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    
    _btnDeleteLogs = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_footerView.frame) - 28) / 2.f, 10, 28, 28)];
    [_btnDeleteLogs setBackgroundImage:[UIImage imageNamed:@"gateway_log_delete"] forState:UIControlStateNormal];
    [_btnDeleteLogs setBackgroundImage:[UIImage imageNamed:@"gateway_log_delete_press"] forState:UIControlStateHighlighted];
    [_btnDeleteLogs addTarget:self action:@selector(onDeleteLogs:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_btnDeleteLogs];
    
    _labelDeleteLogs = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnDeleteLogs.frame) + 6, CGRectGetWidth(_footerView.frame), 11)];
    _labelDeleteLogs.font = [UIFont systemFontOfSize:11];
    _labelDeleteLogs.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelDeleteLogs.text = NSLocalizedStringFromTable(@"mydevice.gateway.log.clear",@"plugin_gateway","清空日志");
    _labelDeleteLogs.textAlignment = NSTextAlignmentCenter;
    [_footerView addSubview:_labelDeleteLogs];

    //Tableview
    // internal table vc
    if (self.tvcInternal == nil) {
        self.tvcInternal = [[MHTableViewControllerInternal alloc] initWithStyle:UITableViewStylePlain];
    }
    self.tvcInternal.delegate = self;
    self.tvcInternal.tableView.allowsSelection = NO;
    CGRect tableRect = CGRectMake(0, 64, CGRectGetWidth(self.view.frame),
                                  _footerView.frame.origin.y - 64);
    [self.tvcInternal.view setFrame:tableRect];
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
}

-(void)onDeleteLogs:(id)sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.log.clear.alert.title",@"plugin_gateway","是否清空所有记录") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway",@"取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定"), nil];
    [alertView show];
    [self gw_clickMethodCountWithStatType:@"onDeleteLogs:"];
}

-(void)fetchLoglist{
    //缓存
    [self.tvcInternal.tableView reloadData];
    [self onGetLatestLogSucceed];
    [self.tvcInternal pullDownToRefresh];
 
    //刷新
    [self getLatestLogList];
}

-(void)getLatestLogList{
    typeof(self) __weak weakSelf = self;
    
    MHGatewayLogListManager* logManager = (MHGatewayLogListManager*)self.dataManager;
    [logManager getLatestLogWithSuccess:^(id obj) {
        [weakSelf onGetLatestLogSucceed];
        [[MHTipsView shareInstance] hide];
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"loading.failed", @"plugin_gateway", nil) duration:1.5f modal:NO];
    }];
}

#pragma mark - log list control
- (void)onGetLatestLogSucceed {
    if (self.onGetLatestLogDescript) self.onGetLatestLogDescript([(MHGatewayLogListManager*)self.dataManager getLatestLogDescription]);
}

- (void)onDataSourceUpdated {
    _btnDeleteLogs.enabled = [self.dataManager getDataListCount] > 0;
}

- (void)onDeleteLogsFinished:(BOOL)isSucceed {
    if (isSucceed) {
        if (self.onGetLatestLogDescript) self.onGetLatestLogDescript([(MHGatewayLogListManager*)self.dataManager getLatestLogDescription]);
    }
    else{
        _btnDeleteLogs.enabled = YES;
    }
}

#pragma mark - MHTableViewControllerInternalDelegate
- (void)startRefresh
{
    [self.dataManager refresh:20];
    [self getLatestLogList];
}

- (void)startGetmore
{
    if ([self.dataManager hasNextPage]) {
        [self.dataManager loadNextPage:20];
    } else {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"mydevice.gateway.log.allload",@"plugin_gateway","已加载全部日志") duration:1.0f modal:NO];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    typeof(self) __weak weakSelf = self;
    switch (buttonIndex) {
        case 1: {
            //确定
            _btnDeleteLogs.enabled = NO;
            [(MHGatewayLogListManager*)self.dataManager deleteAllLogsWithSuccess:^(id obj) {
                [weakSelf onDeleteLogsFinished:YES];
            } failure:^(NSError * error) {
                [weakSelf onDeleteLogsFinished:NO];
            }];
            break;
        }
        default:
            break;
    }
}
@end
