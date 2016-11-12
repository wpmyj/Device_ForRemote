//
//  MHGatewayClockFMCollectViewController.m
//  MiHome
//
//  Created by guhao on 16/4/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayClockFMCollectViewController.h"
#import "MHLuTableViewController.h"
#import "MHLumiFMCollecttionCell.h"
#import "MHLumiFMCollectionInvoker.h"
#import "MHLumiFMTabViewController.h"
#import "MHLumiFmPlayerViewController.h"
#import "MHGatewayMainViewController.h"
#import "MHLumiFmPlayer.h"


@interface MHGatewayClockFMCollectViewController () <MHTableViewControllerInternalDelegate,MHLuTableViewControllerInternalDelegate,UITableViewDelegate>

@property (nonatomic, strong) MHLuTableViewController* tvcInternal;
@property (nonatomic, strong) NSString *localCode;
@property (nonatomic, strong) MHLumiXMPageInfo *pageInfo;
@property (nonatomic, assign) CGRect tableFrame;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MHDeviceGateway *radioDevice;
@property (nonatomic, strong) NSIndexPath *currentRadioIndex;
@property (nonatomic, strong) MHLumiFmPlayer *fmPlayer;

@property (nonatomic, strong) UIButton *rightBarButton;


@end

@implementation MHGatewayClockFMCollectViewController
{
    MHLumiFMCollectionInvoker *     _invoker;
}

- (id)initWithRadioDevice:(MHDeviceGateway *)radioDevice{
    self = [super init];
    if (self) {
        _radioDevice = radioDevice;
     }
    return self;
}

- (void)setTableFrame:(CGRect)tableFrame {
    if(_tableFrame.size.height != tableFrame.size.height){
        _tableFrame = tableFrame;
        [self.tvcInternal.view setFrame:tableFrame];
    }
}

- (void)setCurrentRadioIndex:(NSIndexPath *)currentRadioIndex {
    _currentRadioIndex = currentRadioIndex;
    [self showAnimation:currentRadioIndex];
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.collectionlist", @"plugin_gateway", nil);
    
    _invoker = [[MHLumiFMCollectionInvoker alloc] init];
    _invoker.radioDevice = _radioDevice;
    
    //获取收藏电台缓存表
    [self firstRestoreData];
    
    //获取网关播放信息
    [self fetchRadioDeviceStatus];
}

//获取当前网关fm播放状态
- (void)fetchRadioDeviceStatus {
    XM_WS(weakself);
    
    [_radioDevice fetchRadioDeviceStatusWithSuccess:^(id obj) {
        
        if ([[obj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]){
            NSString *radioId = [[obj valueForKey:@"result"] valueForKey:@"current_program"];
            
            weakself.radioDevice.fm_volume = [[[obj valueForKey:@"result"] valueForKey:@"current_volume"] integerValue];
            
            NSString *status = [[obj valueForKey:@"result"] valueForKey:@"current_status"];
            
            if(status) {
                weakself.radioDevice.current_status = [status isEqualToString:@"pause"] ? 0 : 1;
            }
            if(radioId) {
                [weakself fetchRadioDetailInfo:radioId];
            }
        }
        
    } andFailure:^(NSError *error) {
        NSLog(@"%@",error);
        if (self.dataSource.count) {
            weakself.fmPlayer.currentRadio = self.dataSource.firstObject;
            weakself.fmPlayer.radioPlayList = self.dataSource;
        }
    }];
}

//获取当前节目详情(第一次进入)
- (void)fetchRadioDetailInfo:(NSString *)radioId {
    
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
    
    MHLumiXMDataManager *manager = [MHLumiXMDataManager sharedInstance];
    [manager fetchRadioByIds:@[ radioId ] withSuccess:^(NSArray *radiolist) {
        [[MHTipsView shareInstance] hide];
        
        MHLumiXMRadio *rawRadio = radiolist.firstObject;
        
        [weakself showFmPlayer:rawRadio];
        weakself.fmPlayer.currentRadio = rawRadio;
        weakself.fmPlayer.radioPlayList = weakself.dataSource;
        
        [weakself.tvcInternal stopRefreshAndReload];
        if(weakself.currentRadioIndex) [weakself showAnimation:weakself.currentRadioIndex];
        
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] hide];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.fmPlayer = [MHLumiFmPlayer shareInstance];
    [self fmCallback];
        self.tableFrame = CGRectMake(0,
                                     195,
                                     CGRectGetWidth(self.view.bounds),
                                     CGRectGetHeight(self.view.bounds));
    if (self.currentRadioIndex) [self showAnimation:_currentRadioIndex];
    
    //获取收藏
    XM_WS(weakself);
    [[MHLumiXMDataManager sharedInstance] restoreCollectionRadioDeviceDid:_radioDevice.did
                                                               withFinish:^(NSMutableArray *datalist){
                                                                   [weakself showReceivedData:datalist];
                                                               }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //如果退出，则消除掉player
    NSArray *group = [(UINavigationController *)self.parentViewController childViewControllers];
    if (![group indexOfObject:self]){
        [self hideMiniPlayer];
    }
}

- (void)onBack:(id)sender {
    [self hideMiniPlayer];
    [super onBack:sender];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    
    UIView *navigationHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 64)];
    navigationHeaderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navigationHeaderView];
    
    
    _rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarButton.frame = CGRectMake(0, 0, 44, 26);
    [_rightBarButton setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [_rightBarButton setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
    _rightBarButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
    _rightBarButton.layer.cornerRadius = 3.0f;
    [_rightBarButton addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    CGFloat screen_width = CGRectGetWidth(self.view.frame);
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, screen_width, 55)];
//    titleView.backgroundColor = [UIColor whiteColor];
    
    titleView.backgroundColor = [MHColorUtils colorWithRGB:0xefeff4];
//    [titleView addSubview:headerView];
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 23, screen_width - 40, 30)];
    myLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.mycollection", @"plugin_gateway", nil);
    myLabel.textColor = [MHColorUtils colorWithRGB:0x6d6d72];
    myLabel.font = [UIFont systemFontOfSize:13.f];
    [titleView addSubview:myLabel];
    [self.view addSubview:titleView];
    
    _tableFrame = CGRectMake(0, 119,
                             CGRectGetWidth(self.view.frame),
                             CGRectGetHeight(self.view.frame) - CGRectGetMaxY(titleView.frame));
    if (self.tvcInternal == nil) {
        self.tvcInternal = [[MHLuTableViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    self.tvcInternal.delegate = self;
    self.tvcInternal.luDelegate = self;
    self.tvcInternal.canDelete = YES;
    self.tvcInternal.cellClass = [MHLumiFMCollecttionCell class];
    self.tvcInternal.dataSource = self.dataSource;
    [self.tvcInternal stopRefreshAndReload];
    [self.tvcInternal.view setFrame:_tableFrame];
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
    
    _fmPlayer = [MHLumiFmPlayer shareInstance];
    _fmPlayer.isHide = YES;
    _fmPlayer.radioDevice = _radioDevice;
    MHLumiXMRadio *tmpRadio = [[MHLumiXMRadio alloc] init];
    tmpRadio.radioName = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.noneradio", @"plugin_gateway", nil);
    [self showFmPlayer:tmpRadio];
}

#pragma mark - 数据操作
- (void)firstRestoreData {
    XM_WS(weakself);
    [_invoker fetchCollectionListWithSuccess:^(NSMutableArray *datalist){
        [weakself showReceivedData:datalist];
    } andFailure:nil];
}

- (void)showReceivedData:(NSMutableArray *)datalist {
    self.dataSource = [NSMutableArray arrayWithArray:datalist];
    
    self.tvcInternal.dataSource = self.dataSource;
    self.fmPlayer.radioPlayList = self.dataSource;
    
    [self.tvcInternal stopRefreshAndReload];
}

- (void)removeElement:(MHLumiXMRadio *)radio {
    [_invoker removeElementFromCollection:radio WithSuccess:nil andFailure:nil];
}

#pragma mark - tableview delegte
//通知manager刷新
- (void)startRefresh {
    XM_WS(weakself);
    [_invoker loadlistDataWithSuccess:^(NSMutableArray *datalist) {
        [weakself showReceivedData:datalist];
        
    } andFailure:^(NSError *error) {
        
    }];
}

//根据indexPath获得row高度
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76.f;
}

- (UIView*)emptyView{
    UIView *messageView = [[UIView alloc] initWithFrame:self.view.bounds];
    [messageView setBackgroundColor:[MHColorUtils colorWithRGB:0xefeff4]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
    [messageView addSubview:icon];
    CGRect frame = icon.frame;
    frame.origin.x = messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
    frame.origin.y = CGRectGetHeight(self.view.frame) / 4.f;
    [icon setFrame:frame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(messageView.frame.origin.x, CGRectGetMaxY(icon.frame) + 10.0f, messageView.frame.size.width, 19.0f)];
    label.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.collection.none", @"plugin_gateway", nil);
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:15.0f]];
    [messageView addSubview:label];
    
    return messageView;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"reuseCellId";
    MHLumiFMCollecttionCell* cell = (MHLumiFMCollecttionCell* )[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHLumiFMCollecttionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    id obj = self.dataSource[indexPath.row];
    [cell configureWithDataObject:obj];
    
    XM_WS(weakself);
    cell.onCollectionClicked = ^(MHLumiFMCollecttionCell *cell){
        NSLog(@"%@",obj);
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.center = CGPointMake(-cell.frame.size.width / 2, cell.center.y);
                         }
                         completion:^(BOOL finished) {
                             [weakself.dataSource removeObject:obj];
                             MHLumiXMRadio *radio = [MHLumiXMRadio jsonToObject:obj];
                             [weakself removeElement:radio];
                             [weakself.tvcInternal stopRefreshAndReload];
                         }];
    };
    
    if ([ [obj valueForKey:@"radioId"] isEqualToString:[_fmPlayer.currentRadio valueForKey:@"radioId"]] &&
        _fmPlayer.isPlaying ) {
        cell.isAnimation = YES;
        _currentRadioIndex = indexPath;
        _fmPlayer.currentRadio.radioCollection = @"yes";
    }
    else {
        cell.isAnimation = NO;
    }
    
    cell.onCellClicked = ^(MHLumiFMCollecttionCell *cell){
        weakself.currentRadioIndex = indexPath;
        
        MHLumiXMRadio *radio = weakself.dataSource[indexPath.row];
        [weakself playRadioWith:radio];
        [weakself hideAllCellAnimation];
        
        cell.isAnimation = YES;
    };
    
    return cell;
}

#pragma mark - lu delegate
- (void)deleteTableViewCell:(NSIndexPath *)indexPath {
    id obj = self.dataSource[indexPath.row];
    [self.dataSource removeObject:obj];
    
    MHLumiXMRadio *radio = [MHLumiXMRadio jsonToObject:obj];
    [self removeElement:radio];
    [self.tvcInternal stopRefreshAndReload];
    self.fmPlayer.radioPlayList = self.dataSource;
}
#pragma mark - 确定
- (void)onDone:(id)sender {
    
    if (self.onDone) {
        self.onDone(self.dataSource[self.currentRadioIndex.row]);
    }
    
}




#pragma mark - radio play
- (void)playRadioWith:(MHLumiXMRadio *)radio {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
    
    [_radioDevice playSpecifyRadioWithProgramID:[[radio valueForKey:@"radioId"] integerValue]
                                            Url:[radio valueForKey:@"radioRateUrl"]
                                           Type:@"0"
                                     andSuccess:^(id obj){
                                         [[MHTipsView shareInstance] hide];
                                         weakself.fmPlayer.currentRadio = radio;
                                         weakself.fmPlayer.radioPlayList = weakself.dataSource;
                                         weakself.fmPlayer.isPlaying = YES;
                                         
                                     } andFailure:^(NSError *error){
                                         [[MHTipsView shareInstance] hide];
                                         NSLog(@"%@",error);
                                     }];
}

- (void)showAnimation:(NSIndexPath *)indexPath {
    [self.tvcInternal.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    MHLumiFMCollecttionCell *cell = (MHLumiFMCollecttionCell *)[self.tvcInternal.tableView cellForRowAtIndexPath:indexPath];
    cell.isAnimation = YES;
}

- (void)hideAllCellAnimation {
    for (MHLumiFMCollecttionCell *obj in self.tvcInternal.tableView.visibleCells){
        obj.isAnimation = NO;
    }
}

- (void)showFmPlayer:(id)radio {
    self.tableFrame = CGRectMake(0,
                                 119,
                                 CGRectGetWidth(self.view.bounds),
                                 CGRectGetHeight(self.view.bounds) - 119);
//

    self.fmPlayer.isPlaying = self.radioDevice.current_status;
    self.fmPlayer.currentRadio = radio;
    self.fmPlayer.radioPlayList = self.dataSource;
    
    [self fmCallback];
}

- (void)fmCallback {
    XM_WS(weakself);
    self.fmPlayer.playCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself hideAllCellAnimation];
        
        weakself.currentRadioIndex = [weakself fetchCurrentRadioIndex:currentRadio];
    };
    
    self.fmPlayer.pauseCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself hideAllCellAnimation];
    };

}

- (NSIndexPath *)fetchCurrentRadioIndex:(MHLumiXMRadio *)currentRadio {
    __block NSIndexPath *indexPath ;
    [self.dataSource enumerateObjectsUsingBlock:^(MHLumiXMRadio *obj, NSUInteger idx, BOOL *stop) {
        if ([[obj valueForKey:@"radioId"] isEqual:[currentRadio valueForKey:@"radioId"]]){
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    
    return indexPath;
}



- (void)hideMiniPlayer {
    self.tableFrame = CGRectMake(0, 119,
                                 CGRectGetWidth(self.view.frame),
                                 CGRectGetHeight(self.view.frame) - 119);
    [_fmPlayer hide];
    [_fmPlayer pause];
}

@end
