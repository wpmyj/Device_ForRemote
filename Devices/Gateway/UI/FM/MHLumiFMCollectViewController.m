//
//  MHLumiFMViewController.m
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMCollectViewController.h"
//#import "MHTableViewControllerInternal.h"
#import "MHLuTableViewController.h"
#import "MHLumiFMCollecttionCell.h"
#import "MHLumiFMCollectionInvoker.h"
#import "MHLumiFMTabViewController.h"
#import "MHLumiFmPlayerViewController.h"
#import "MHGatewayMainViewController.h"
#import "MHGatewayPopMenuView.h"

#define kSmooth          NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.rate.low",@"plugin_gateway","")
#define kSmoothTitle     NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.rate.low.title",@"plugin_gateway","")
#define kStandard        NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.rate.high",@"plugin_gateway","")
#define KStandardTitle   NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.rate.high.title",@"plugin_gateway","")


@interface MHLumiFMCollectViewController () <MHTableViewControllerInternalDelegate,MHLuTableViewControllerInternalDelegate,UITableViewDelegate, MHGatewayPopMenuViewDelegate>

@property (nonatomic, strong) MHLuTableViewController* tvcInternal;
@property (nonatomic, strong) NSString *localCode;
@property (nonatomic, strong) MHLumiXMPageInfo *pageInfo;
@property (nonatomic, assign) CGRect tableFrame;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MHDeviceGateway *radioDevice;
@property (nonatomic, strong) NSIndexPath *currentRadioIndex;

@property (nonatomic, strong) NSArray *popMenuArray;
@property (nonatomic, strong) UIButton *rightBarButton;
@property (nonatomic, assign) BOOL isLowRate;


@end

@implementation MHLumiFMCollectViewController
{
    MHLumiFMCollectionInvoker *     _invoker;
}

- (id)initWithRadioDevice:(MHDeviceGateway *)radioDevice{
    self = [super init];
    if (self) {
        _radioDevice = radioDevice;
        self.isLowRate = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"fmRate%@", self.radioDevice.did]] boolValue];
        self.popMenuArray = @[ @{ @"title": kSmoothTitle, @"identifier": @"Low", @"seleted": @(self.isLowRate) },
                               @{  @"title": KStandardTitle, @"identifier": @"High", @"seleted": @(!self.isLowRate) }
                               ];
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
    if(!self.fmPlayer.isHide) {
        self.tableFrame = CGRectMake(0,
                                     195,
                                     CGRectGetWidth(self.view.bounds),
                                     CGRectGetHeight(self.view.bounds) - 195 - MiniPlayerHeight);
    }
    
    if (self.currentRadioIndex) [self showAnimation:_currentRadioIndex];
    
    //获取收藏
    XM_WS(weakself);
    [[MHLumiXMDataManager sharedInstance] restoreCollectionRadioDeviceDid:_radioDevice.did
                                                               withFinish:^(NSMutableArray *datalist){
                                                                   [weakself showReceivedData:datalist];
                                                               }];
    //音乐品质
    [self getFmRate];
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
    [[MHTipsView shareInstance] hide];
    NSLog(@"首页的fmplayer数据%ld", self.fmPlayer.radioPlayList.count);
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
    _rightBarButton.layer.borderWidth = 1.0f;
    _rightBarButton.layer.borderColor = [MHColorUtils colorWithRGB:0x858585].CGColor;
    _rightBarButton.layer.cornerRadius = 5.0f;
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:self.isLowRate ?  kSmooth : kStandard];
    [titleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, kSmooth.length)];
    [titleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, kSmooth.length)];
    [_rightBarButton setAttributedTitle:titleAttribute forState:UIControlStateNormal];
    [_rightBarButton addTarget:self action:@selector(fmRateChoose:) forControlEvents:UIControlEventTouchUpInside];
    _rightBarButton.frame = CGRectMake(0, 0, 40, 30);
    _rightBarButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButton];
    
    self.navigationItem.rightBarButtonItem = rightItem;

    
    CGFloat screen_width = CGRectGetWidth(self.view.frame);
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, screen_width, 131)];
    titleView.backgroundColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 55)];
    headerView.backgroundColor = [MHColorUtils colorWithRGB:0xefeff4];
    [titleView addSubview:headerView];
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 23, screen_width - 40, 30)];
    myLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.mycollection", @"plugin_gateway", nil);
    myLabel.textColor = [MHColorUtils colorWithRGB:0x6d6d72];
    myLabel.font = [UIFont systemFontOfSize:13.f];
    [titleView addSubview:myLabel];
    
    UIImageView *addImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_fm_addcollection"]];
    addImage.frame = CGRectMake(20, 65, 58, 58);
    [titleView addSubview:addImage];

    UIImageView *showMoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_fm_add_next"]];
    showMoreImage.frame = CGRectMake(0, 0, 17, 17);
    showMoreImage.center = CGPointMake(screen_width - 40, addImage.center.y);
    [titleView addSubview:showMoreImage];

    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, 73, screen_width - CGRectGetMinX(showMoreImage.frame), 45)];
    addLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.addcollection", @"plugin_gateway", nil);
    addLabel.textColor = [MHColorUtils colorWithRGB:0x000000];
    addLabel.alpha = 0.5;
    addLabel.font = [UIFont systemFontOfSize:16.f];
    [titleView addSubview:addLabel];
    
    UIView *upLine = [[UIView alloc] initWithFrame:CGRectMake(20, 55, screen_width - 40, 1.f)];
    upLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [titleView addSubview:upLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(20, 130, screen_width - 40, 1.f)];
    bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [titleView addSubview:bottomLine];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 55, CGRectGetWidth(self.view.frame), 76)];
    [addBtn addTarget:self action:@selector(onCollectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:addBtn];
    
    [self.view addSubview:titleView];

    _tableFrame = CGRectMake(0, CGRectGetMaxY(titleView.frame),
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

- (void)onCollectionBtnClicked:(id)sender {
    MHLumiFMTabViewController *tab = [[MHLumiFMTabViewController alloc] initWithRadio:_radioDevice];
    tab.fmPlayer = _fmPlayer;
    [self.navigationController pushViewController:tab animated:YES];
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
#pragma mark - 品质选择
- (void)fmRateChoose:(id)sender {
    
    MHGatewayPopMenuView *popMenuView = [[MHGatewayPopMenuView alloc] initWithFrame:CGRectMake(WIN_WIDTH - 120, 64 - 5, 100, 44 * 2 + 12)];
    popMenuView.delegate = self;
    
    [popMenuView showViewInView:self.navigationController.view];
    
}

- (void)getFmRate {
    XM_WS(weakself);
    [self.radioDevice getDeviceProp:ARMING_PRO_FM_LOW_RATE allValue:NO success:^(id obj) {
        if ([obj isKindOfClass:[NSArray class]] && [(NSArray *)obj count] > 0) {
            weakself.isLowRate = [[obj firstObject] boolValue];
            [[NSUserDefaults standardUserDefaults] setObject:@(weakself.isLowRate) forKey:[NSString stringWithFormat:@"fmRate%@", weakself.radioDevice.did]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)updatePopMenu:(MHGatewayPopMenuView*)popMenuView {
    self.popMenuArray = @[ @{ @"title" : kSmoothTitle, @"identifier": @"Low", @"seleted": @(self.isLowRate) },
                           @{ @"title" : KStandardTitle, @"identifier": @"High", @"seleted": @(!self.isLowRate) }
                               ];
//    [self.rightBarButton setTitle:self.isLowRate ? kSmooth : kStandard forState:UIControlStateNormal];
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:self.isLowRate ?  kSmooth : kStandard];
    [titleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, kSmooth.length)];
    [titleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, kSmooth.length)];
    [_rightBarButton setAttributedTitle:titleAttribute forState:UIControlStateNormal];
    [popMenuView updateData];
    [popMenuView hideView];
    
}

#pragma mark - MHGatewayPopMenuViewDelegate
- (void)popMenuView:(MHGatewayPopMenuView*)popMenuView didSelectedRow:(NSInteger)index identifier:(NSString *)identifier {
    XM_WS(weakself);
    if ([identifier isEqualToString:@"High"]) {
        [self.radioDevice setDeviceProp:ARMING_PRO_FM_LOW_RATE value:@(0) success:^(id respObj) {
            NSLog(@"%@", respObj);
            weakself.isLowRate = NO;
            [weakself updatePopMenu:popMenuView];
        } failure:^(NSError *v) {
            [popMenuView hideView];
        }];
    }
    if ([identifier isEqualToString:@"Low"]) {
        [self.radioDevice setDeviceProp:ARMING_PRO_FM_LOW_RATE value:@(1) success:^(id respObj) {
            weakself.isLowRate = YES;
            [weakself updatePopMenu:popMenuView];
        } failure:^(NSError *v) {
            [popMenuView hideView];
        }];
    }
}

- (NSArray*)popMenuDataSource {
    return self.popMenuArray;
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
//    NSLog(@"当前的播放了列表%@ 行数%ld, 段数%ld", self.dataSource, indexPath.row, indexPath.section);
    if (self.tvcInternal.dataSource.count && indexPath.row < self.tvcInternal.dataSource.count) {
        [self.tvcInternal.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        MHLumiFMCollecttionCell *cell = (MHLumiFMCollecttionCell *)[self.tvcInternal.tableView cellForRowAtIndexPath:indexPath];
        cell.isAnimation = YES;
    }
}

- (void)hideAllCellAnimation {
    for (MHLumiFMCollecttionCell *obj in self.tvcInternal.tableView.visibleCells){
        obj.isAnimation = NO;
    }
}

- (void)showFmPlayer:(id)radio {
    self.tableFrame = CGRectMake(0,
                                 195,
                                 CGRectGetWidth(self.view.bounds),
                                 CGRectGetHeight(self.view.bounds) - 195 - MiniPlayerHeight);
    
    if(self.fmPlayer.isHide){
        self.fmPlayer = [MHLumiFmPlayer shareInstance];
        [self.fmPlayer showMiniPlayer:CGRectGetMaxY(self.view.bounds) - MiniPlayerHeight isMainPage:NO];
    }
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
    
    self.fmPlayer.showFullPlayerCallBack = ^() {
        [weakself showFullPlayer];
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

- (void)showFullPlayer {
    MHLumiFmPlayerViewController *fullPlayer = [[MHLumiFmPlayerViewController alloc] init];
    fullPlayer.miniPlayer = [MHLumiFmPlayer shareInstance];
    
    XM_WS(weakself);
    [self presentViewController:fullPlayer animated:YES completion:^{
        weakself.fmPlayer.hidden = YES;
    }];
}

- (void)hideMiniPlayer {
    self.tableFrame = CGRectMake(0, 195,
                                 CGRectGetWidth(self.view.frame),
                                 CGRectGetHeight(self.view.frame) - 195);
    [_fmPlayer hide];
}

@end
