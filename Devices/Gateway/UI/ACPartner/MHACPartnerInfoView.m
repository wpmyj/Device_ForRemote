//
//  MHACPartnerInfoView.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerInfoView.h"
#import "MHGatewayInfoFolderCell.h"
#import "MHGatewayInfoSensorCell.h"
#import "MHDeviceGatewaySensorHumiture.h"
#import "MHDeviceChangeNameView.h"
#import "MHLumiChangeIconManager.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHGetSubDataResponse.h"
#import "MHLumiLogGraphManager.h"

#define TableViewCellHeight 60.f

#define LoopDataInterval    6.0

static NSString* folderCellIdentifier = @"cell";
static NSString* sensorCellIdentifier = @"sensorCell";

static NSDictionary *sensorTypeName = nil;


@interface MHACPartnerInfoView () <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>


@property (nonatomic,strong) MHDeviceAcpartner *acpartner;
@property (nonatomic,strong) NSMutableArray *infoSensors;
@property (nonatomic,strong) void(^callbackCurrentHeight)(CGFloat height);
@property (nonatomic,strong) NSMutableArray *sourceArray;        //用户展示的 tableview datasource
@property (nonatomic,strong) NSMutableDictionary *sensorLatestLogDic;
@property (nonatomic,strong) MHDeviceGatewayBase *longPressedSensor;

@end

@implementation MHACPartnerInfoView

{
    CGFloat                 _currentHeight;
    
    NSMutableArray *        _folderArray;        //所有folder
    NSMutableDictionary *   _folderSourceDic;    //folder对应的sensor
    
    BOOL                    _showChangeLogo;
}

- (id)initWithFrame:(CGRect)frame
             sensor:(MHDeviceAcpartner* )acpartner
         subDevices:(NSArray *)subDevices
     callbackHeight:(void (^)(CGFloat height))callbackHeight {
    
    if (self = [super initWithFrame:frame]) {
        sensorTypeName = @{
                           @"MHDeviceGatewaySensorCube" : NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.cube", @"plugin_gateway", nil),
                           @"MHDeviceGatewaySensorMotion" : NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.motion", @"plugin_gateway", nil),
                           @"MHDeviceGatewaySensorMagnet" : NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.magnet", @"plugin_gateway", nil),
                           @"MHDeviceGatewaySensorSwitch" : NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.switch", @"plugin_gateway", nil),
                           @"MHDeviceGatewaySensorHumiture" : NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.humiture", @"plugin_gateway", nil),
                           @"MHDeviceGatewaySensorDoubleSwitch" : NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.doubleswitch", @"plugin_gateway", nil),
                           @"MHDeviceGatewaySensorSingleSwitch" : NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.singleswitch", @"plugin_gateway", nil),
                           };
        self.acpartner = acpartner;
        _currentHeight = frame.size.height;
        _infoSensors = [NSMutableArray arrayWithArray:subDevices];
        _callbackCurrentHeight = callbackHeight;
        [self buildSensors];
        [self buildSubviews];
    }
    return self;
}

- (void)dealloc {
    //    [self stopWatchingLatestLog];
}

- (void)buildSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 36)];
    sectionView.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
    [self addSubview:sectionView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 80, 20)];
    titleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    titleLabel.font = [UIFont systemFontOfSize:13.f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.panel.info", @"plugin_gateway", nil);
    [self addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 36, WIN_WIDTH, 0.7)];
    line.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
    [self addSubview:line];
    
    CGRect selfFrame = self.frame;
    CGFloat sX = CGRectGetMinX(selfFrame);
    CGFloat sY = CGRectGetMinY(selfFrame);
    CGFloat sWidth = CGRectGetWidth(selfFrame);
    CGFloat sHeight = 37 + TableViewCellHeight * _folderArray.count;
    self.frame = CGRectMake(sX, sY, sWidth, sHeight);
    if(self.callbackCurrentHeight) {
        self.callbackCurrentHeight(sHeight);
    }
    
    CGRect tableFrame = CGRectMake(0, 37, WIN_WIDTH, sHeight - 37);
    _tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[MHGatewayInfoFolderCell class] forCellReuseIdentifier:folderCellIdentifier];
    [_tableView registerClass:[MHGatewayInfoSensorCell class] forCellReuseIdentifier:sensorCellIdentifier];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, sHeight - 37)];
    footerView.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
    _tableView.tableFooterView = footerView;
    [self addSubview:_tableView];
    
    [self fetchLatestLog];
}

- (void)buildSensors {
    _folderArray = [NSMutableArray new];
    _folderSourceDic = [NSMutableDictionary new];
    _sourceArray = [NSMutableArray new];
    
    for (MHDeviceGatewayBase *sensor in _infoSensors){
        [[MHLumiChooseLogoListManager sharedInstance] isShowLogoListWithandDeviceModel:sensor.model finish:nil];
        [sensor buildServices];
        
        NSString *className = NSStringFromClass([sensor class]);
        if([_folderArray indexOfObject:className] == NSNotFound){
            [_folderArray addObject:className];
            [_folderSourceDic setObject:@[ sensor ] forKey:className];
        }
        else {
            NSMutableArray *tmp = [[_folderSourceDic valueForKey:className] mutableCopy];
            [tmp addObject:sensor];
            [_folderSourceDic setObject:tmp forKey:className];
        }
    }
    
    int folderId = 0; // 为folder编码Id，便于后续查找
    for(NSString *cls in _folderArray) {
        NSDictionary *info = @{
                               @"folderId" : @(folderId++),
                               @"cellName" : [sensorTypeName valueForKey:cls] ? [sensorTypeName valueForKey:cls] : @"",
                               @"class" : cls,
                               @"count" : @([[_folderSourceDic valueForKey:cls] count]),
                               @"sensors" : [_folderSourceDic valueForKey:cls],
                               @"isFolderCell" : @(1),
                               };
        [_sourceArray addObject:info];
    }
}

- (void)setSourceArray:(NSMutableArray *)sourceArray {
    if(_sourceArray != sourceArray){
        [_tableView reloadData];
    }
}

#pragma mark - 定期获取最新日志
- (void)fetchLatestLog {
    NSLog(@"-------- fetch latest log --------");
    XM_WS(weakself);
    __block NSMutableArray *htDevices = [NSMutableArray new];
    [_infoSensors enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL *stop) {
        if(sensor.isOnline){
            if([sensor isKindOfClass:[MHDeviceGatewaySensorHumiture class]]) {
                //                [(MHDeviceGatewaySensorHumiture *)sensor getDeviceProp:@[LUMI_HUMITURE_TEMP_PROP,LUMI_HUMITURE_HUMIDITY_PROP]
                //                                                               success:^(id obj) { [weakself.tableView reloadData]; }
                //                                                               failure:nil];
                [htDevices addObject:sensor];
            }
            else {
                __block __weak MHDeviceGatewayBase *newSensor = sensor;
                [sensor.logManager getLatestLogWithSuccess:^(MHGetSubDataResponse *obj) {
                    if([obj isKindOfClass:NSClassFromString(@"MHGetSubDataResponse")] &&
                       [newSensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")]) {
                        if([[[obj.logs lastObject] key] isEqualToString:@"open"]){
                            newSensor.isOpen = YES;
                        }
                        else {
                            newSensor.isOpen = NO;
                        }
                        if([sensor isKindOfClass:[MHDeviceGatewayBase class]]) [newSensor buildServices];
                    }
                    [weakself.tableView reloadData];
                } failure:nil];
            }
        }
    }];
    
    NSInteger propIndex = htDevices.count / kMAXDEVICESPROPCOUNT + 1;
    if (!htDevices.count) {
        return;
    }
    for (NSInteger i = 0; i < propIndex; i++) {
        NSMutableArray *devices = [NSMutableArray new];
        for (NSInteger idx = i * kMAXDEVICESPROPCOUNT; idx < (i + 1) * kMAXDEVICESPROPCOUNT; idx++) {
            if (idx >= htDevices.count) {
                break;
            }
            [devices addObject:htDevices[idx]];
        }
        [_acpartner gePropDevices:devices success:^(id obj) {
            [weakself.tableView reloadData];
        } failure:^(NSError *error) {
            //            NSLog(@"拉取温湿度失败%@", error);
        }];
    }
}

//- (void)startWatchingLatestLog {
//    if (self.shouldKeepRunning) {
//        return;
//    }
//    self.shouldKeepRunning = YES;
//
//    [self.timer invalidate];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:LoopDataInterval
//                                                  target:self
//                                                selector:@selector(fetchLatestLog)
//                                                userInfo:nil repeats:YES];
//    [self.timer fire];
//}

//- (void)stopWatchingLatestLog {
//    [self.timer invalidate];
//    self.timer = nil;
//    self.shouldKeepRunning = NO;
//}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XM_WS(weakself);
    NSDictionary *info = _sourceArray[indexPath.row];
    if([[info valueForKey:@"isFolderCell"] intValue]) {
        MHGatewayInfoFolderCell* cell = (MHGatewayInfoFolderCell *)[tableView dequeueReusableCellWithIdentifier:folderCellIdentifier];
        [cell configureWithDataObject:info];
        cell.longPressed = ^(MHGatewayInfoFolderCell *cell){
            if([[info valueForKey:@"sensors"] count] == 1){
                MHDeviceGatewayBase *sensor = [[info valueForKey:@"sensors"] firstObject];
                [weakself longPressed:sensor];
            }
        };
        return cell;
    }
    else {
        MHGatewayInfoSensorCell* cell = (MHGatewayInfoSensorCell *)[tableView dequeueReusableCellWithIdentifier:sensorCellIdentifier];
        [cell configureWithDataObject:info];
        cell.longPressed = ^(MHGatewayInfoSensorCell *cell){
            NSLog(@"%@",cell);
            MHDeviceGatewayBase *sensor = [[info valueForKey:@"sensors"] firstObject];
            [weakself longPressed:sensor];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id clickedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    //如果点击的是folder，进行展开／收起操作
    if([clickedCell isKindOfClass:[MHGatewayInfoFolderCell class]]) {
        MHGatewayInfoFolderCell *folderCell = (MHGatewayInfoFolderCell *)clickedCell;
        
        //是否支持展开和合并
        if(folderCell.canUnfold){
            if(!folderCell.shouldfold){
                //展开 －－ 向数据源中加入sensor数据
                [self rebuildDatasource:folderCell.folderInfo isAdd:YES];
                folderCell.shouldfold = YES;
            }
            else {
                //收起 －－ 将数据源中对应的sensor数据移除
                [self rebuildDatasource:folderCell.folderInfo isAdd:NO];
                folderCell.shouldfold = NO;
            }
        }
        else {
            //打开设备
            MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[[folderCell.folderInfo valueForKey:@"sensors"] firstObject];
            [self openDeviceLogPage:sensor];
        }
    }
    else {
        MHGatewayInfoSensorCell *sensorCell = (MHGatewayInfoSensorCell *)clickedCell;
        //打开设备
        MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[[sensorCell.sensorInfo valueForKey:@"sensors"] firstObject];
        [self openDeviceLogPage:sensor];
    }
}

#pragma mark - 打开设备页
- (void)openDeviceLogPage:(MHDeviceGatewayBase *)sensor {
    if([sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorHumiture")]){
        if(sensor.isOnline){
            if(self.openDevicePageCallback) self.openDevicePageCallback(sensor);
        }
        else {
            [_tableView reloadData];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.offlineview.just.tips", @"plugin_gateway", nil) duration:1.5f modal:NO];
        }
    }
    else {
        if(self.openDeviceLogPageCallback) self.openDeviceLogPageCallback(sensor);
    }
}

#pragma mark - 处理数据源
- (void)rebuildDatasource:(NSDictionary *)folderCellInfo isAdd:(BOOL)isAdd{
    int folderId = [[folderCellInfo valueForKey:@"folderId"] intValue];
    
    //查找 folderId 在 _sourceArray 中的位置
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"folderId = %d",folderId]];
    id obj = [[_sourceArray filteredArrayUsingPredicate:predicate] firstObject];
    NSInteger locateIndex = [_sourceArray indexOfObject:obj];
    
    if(isAdd){
        //需要处理的sensors
        NSArray *sensors = [NSArray new];
        if(folderId < _folderArray.count){
            sensors = [_folderSourceDic valueForKey:_folderArray[folderId]];
        }
        
        int sensorId = 0;
        for (MHDeviceGatewayBase *sensor in sensors){
            NSDictionary *info = @{
                                   @"folderId" : @(folderId),
                                   @"sensorId" : @(sensorId ++),
                                   @"cellName" : sensor.name,
                                   @"class" : NSStringFromClass([sensor class]),
                                   @"count" : @(1),
                                   @"sensors" : @[sensor],
                                   @"isFolderCell" : @(0),
                                   };
            if( (locateIndex + sensorId) <= _sourceArray.count )
                [_sourceArray insertObject:info atIndex:(locateIndex + sensorId)];
        }
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"folderId = %d && isFolderCell = 0",folderId]];
        NSArray *sensors = [_sourceArray filteredArrayUsingPredicate:predicate];
        [_sourceArray removeObjectsInArray:sensors];
    }
    [_tableView reloadData];
    
    _currentHeight = _sourceArray.count * TableViewCellHeight + 37;
    CGRect selfFrame = self.frame;
    self.frame = CGRectMake(selfFrame.origin.x, selfFrame.origin.y, selfFrame.size.width, _currentHeight);
    CGRect tableFrame = CGRectMake(0, 37, WIN_WIDTH, _currentHeight - 37);
    _tableView.frame = tableFrame;
    if(self.callbackCurrentHeight)self.callbackCurrentHeight(_currentHeight);
}

#pragma mark - pressed
- (void)longPressed:(MHDeviceGatewayBase *)sensor {
    _longPressedSensor = sensor;
    [_longPressedSensor buildServices];
    _showChangeLogo = [[MHLumiChooseLogoListManager sharedInstance] isShowLogoListWithandDeviceModel:sensor.model finish:nil];
    
    if(_longPressedSensor.services.count){
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:sensor.name
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway", nil)
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil];
        if(_showChangeLogo)
            [action addButtonWithTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo", @"plugin_gateway", @"换图标")];
        [action addButtonWithTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.changename", @"plugin_gateway", @"重命名")];
        if([_longPressedSensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorHumiture")])
            [action addButtonWithTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.humiture.history", @"plugin_gateway", @"历史曲线")];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [action showInView:window];
    }
}

#pragma mark - action delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex){
        case 1:
            if(_showChangeLogo)[self changLogo];
            else [self changeName];
            break;
        case 2:
            if([_longPressedSensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorHumiture")]){
                if(self.openDeviceLogPageCallback)self.openDeviceLogPageCallback(_longPressedSensor);
            }
            else [self changeName];
            break;
        default:
            break;
    }
}

#pragma mark - change service
- (void)changLogo {
    XM_WS(weakself);
    __block MHDeviceGatewayBaseService *oldService = _longPressedSensor.services[0];
    NSString *iconId = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:oldService
                                                                 withCompletionHandler:^(id result, NSError *error) { }];
    oldService.serviceIconId = iconId;
    if(self.chooseServiceIcon) self.chooseServiceIcon(oldService);
    MHLumiChooseLogoListManager *logoChooseManager = [MHLumiChooseLogoListManager sharedInstance];
    logoChooseManager.setIconSuccessed = ^(MHDeviceGatewayBaseService *service){
        oldService = service;
        [weakself.tableView reloadData];
    };
}

- (void)changeName {
    XM_WS(weakself);
    MHDeviceGatewayBaseService *service = _longPressedSensor.services[0];
    CGFloat ratio = [UIScreen mainScreen].bounds.size.width / 414.0f;
    MHDeviceChangeNameView* changeNameView = [[MHDeviceChangeNameView alloc] initWithFrame:[UIScreen mainScreen].bounds panelFrame:CGRectMake(20 * ratio, 100, ([UIScreen mainScreen].bounds.size.width-40 * ratio), 195 * ratio) withCancel:^(id object){
    } withOk:^(NSString* newName){
        service.serviceName = newName;
        [service changeName];
    }];
    [changeNameView setName:_longPressedSensor.name];
    [self.window addSubview:changeNameView];
    
    service.serviceChangeNameFailure = ^(NSError *error){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.failed", @"plugin_gateway", @"修改设备名称失败") duration:1.5 modal:NO];
    };
    service.serviceChangeNameSuccess = ^(id obj){
        [weakself.tableView reloadData];
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.succeed", @"plugin_gateway", @"修改设备名称成功") duration:1.5 modal:NO];
    };
}


@end
