//
//  MHGatewayClockBellChooseViewController.m
//  MiHome
//
//  Created by guhao on 16/4/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayClockBellChooseViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHGatewayCloudMusicViewController.h"
#import "MHGatewayRecordButtonView.h"
#import "MHGwMusicInvoker.h"
#import "MHGatewayBellChooseCell.h"
#import "MHMusicTipsView.h"
#import "MHGatewayUserDefineCell.h"
#import "MHGatewayClockRecordViewController.h"
#import "MHGatewayClockFMCollectViewController.h"
#import "MHLumiFmPlayer.h"

#define ACDeleteFile 10001
#define ACDownloadList 10002
#define ACChooseType   10003
@interface MHGatewayClockBellChooseViewController ()<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)  UITableView* tableView;
@property (nonatomic,strong) UIView  *footerView;
@property (nonatomic, strong) MHGatewayClockRecordViewController *recordVC;

@property (nonatomic,strong)  MHDeviceGateway *gateway;
@property (nonatomic,strong)  NSMutableArray *gatewayGroup;
@property (nonatomic,strong)  NSMutableArray *userGroup;
@property (nonatomic,assign)  BOOL fileExistFlag;
@property (nonatomic,assign)  NSIndexPath *selectedIndexPath;

@end

@implementation MHGatewayClockBellChooseViewController {
    NSInteger                               _musicGroup;
    NSDictionary*                           _bellLocalNames;
    NSInteger                               _selectedRow;
    NSInteger                               _selectedSection;
    NSInteger                               _sectionCount;
    
    MHGwMusicInvoker *                      _invoker;
    MHGatewayBellChooseCell *               _bellChooseCell;
    NSTimer *                               _timer;
    int                                     _imageTmpIndex;
    
    BOOL                                    _alarmClockTimerTypeFlag;
    NSInteger                               _alarmClockSelectedMid;
    
    UIButton *                              _btnAddDevice;
    UILabel *                               _labelAddDevice;
}


- (id)initWithGateway:(MHDeviceGateway*)gateway mid:(NSInteger)mid {
    if (self = [super init]) {
        _alarmClockTimerTypeFlag = YES;
        _gateway = gateway;
        _alarmClockSelectedMid = mid;
        [self createRecord];
        _musicGroup = 2;
        _selectedRow = -1;
        _selectedSection = -1;
        _sectionCount = 1;
        _fileExistFlag = [_recordVC recordFileExist];
    }
    return self;
}

-(void)reloadGatewayMusic:(void (^)(NSError *error))finish{
    XM_WS(weakself);
    [_gateway getMusicInfoWithGroup:_musicGroup Success:^(id v) {
        [weakself onGetMusicListSucceeed];
        [weakself setGatewayDownloadList];
        if(finish)finish(nil);
        
    } failure:^(NSError *error) {
        if(finish)finish(error);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    
    [self onGetMusicListSucceeed];
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];
    [self reloadGatewayMusic:^(NSError *error){
        [[MHTipsView shareInstance] hide];
        if(error)
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
    [self getGatewayDownloadList];
}

- (void)onBack:(id)sender {
    [super onBack:sender];
    [_gateway setSoundPlaying:@"off" success:nil failure:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [_footerView pause];
    [self.recordVC pause];
    [[MHTipsView shareInstance] hide];
}

- (void)buildSubviews {
    self.isTabBarHidden = YES;
    //    UIImage* imageConnect = [[UIImage imageNamed:@"device_connect_normal_icon"] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    //    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:imageConnect style:UIBarButtonItemStylePlain target:self action:@selector(onAddBtnClicked:)];
    //    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGRect rect = CGRectMake(0, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-68);//self.view.bounds;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MHGatewayBellChooseCell class] forCellReuseIdentifier:BellChooseCellId];
    [self.tableView registerClass:[MHGatewayUserDefineCell class] forCellReuseIdentifier:UserDefinedCellId];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    //Footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 65, CGRectGetWidth(self.view.bounds), 65)];
    _footerView.backgroundColor = [UIColor whiteColor];
    if (self.gateway.shareFlag == MHDeviceShared) {
        _footerView.hidden = YES;
    }
    [self.view addSubview:_footerView];
    
    _btnAddDevice = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_footerView.frame) - 28) / 2.f, 5, 28, 28)];
    [_btnAddDevice setBackgroundImage:[UIImage imageNamed:@"device_addtimer"] forState:UIControlStateNormal];
    [_btnAddDevice addTarget:self action:@selector(onAddNewBell:) forControlEvents:UIControlEventTouchUpInside];
    if (self.gateway.shareFlag == MHDeviceShared) {
        _btnAddDevice.hidden = YES;
    }
    
    [_footerView addSubview:_btnAddDevice];
    
    _labelAddDevice = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnAddDevice.frame) + 6,
                                                                CGRectGetWidth(_footerView.frame), 11)];
    _labelAddDevice.font = [UIFont systemFontOfSize:11];
    _labelAddDevice.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelAddDevice.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.adder",@"plugin_gateway", @"添加铃音");
    _labelAddDevice.textAlignment = NSTextAlignmentCenter;
    [_footerView addSubview:_labelAddDevice];

}

#pragma mark - 添加铃音
- (void)onAddNewBell:(id)sender {
    XM_WS(weakself);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.adder",@"plugin_gateway","添加铃音") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *fm = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.collectionlist",@"plugin_gateway","网络收音机电台") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself onFmPlayer];
        }];
    UIAlertAction *record = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record",@"plugin_gateway","录音") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakself onRecord];
                }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.cancle",@"plugin_gateway","取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:record];
        [alert addAction:fm];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.adder",@"plugin_gateway", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.cancle",@"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record",@"plugin_gateway","录音"),NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.player.collectionlist",@"plugin_gateway","网络收音机电台"), nil];
    [alert show];
    }

}

#pragma mark - 录音
- (void)createRecord {
    __weak typeof(self) weakSelf = self;
    self.recordVC = [[MHGatewayClockRecordViewController alloc] initWithGateway:self.gateway];
    
    self.recordVC.recordSuccess = ^(){
        [weakSelf onGetMusicListSucceeed];
    };
    self.recordVC.playStoped = ^(){
        [weakSelf stopAnimation];
    };
    self.recordVC.uploadSuccess = ^(NSDictionary *fileinfo){
        [weakSelf deleteFile];
        
        MHSafeDictionary *info = [MHSafeDictionary dictionaryWithDictionary:fileinfo];
        
        NSString *mid = [[info objectForKey:@"mid" class:[NSNumber class]] stringValue];
        NSString *time = [info objectForKey:@"time" class:[NSNumber class]];
        [weakSelf.userGroup addObject:@{@"mid":mid,@"index":mid,@"time":time}];
        [weakSelf.gateway.music_list setObject:weakSelf.userGroup forKey:@"9"];
        [weakSelf onGetMusicListSucceeed];
        [weakSelf reloadGatewayMusic:nil];
    };
 
}
- (void)onRecord {
    
    [self.navigationController pushViewController:self.recordVC animated:YES];
}
#pragma mark - FM
- (void)onFmPlayer {
    MHGatewayClockFMCollectViewController *fmVC = [[MHGatewayClockFMCollectViewController alloc] initWithRadioDevice:self.gateway];
    fmVC.onDone = ^(MHLumiXMRadio *selectedRadio){
        
    };
    [self.navigationController pushViewController:fmVC animated:YES];
}



- (void)onAddBtnClicked:(id)sender {
    XM_WS(weakself);
    MHGatewayCloudMusicViewController *cloudMusic = [[MHGatewayCloudMusicViewController alloc] initWithGateway:_gateway];
    cloudMusic.returnStateBlock=^(BOOL state){
        if(state)[weakself reloadGatewayMusic:nil];
    };
    cloudMusic.isTabBarHidden = YES;
    cloudMusic.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.adder",@"plugin_gateway","添加铃声");
    
    [self gw_clickMethodCountWithStatType:@"onAddBtnClicked"];
    
    [self.navigationController pushViewController:cloudMusic animated:YES];
}

#pragma mark - 获取音乐列表
- (void)onGetMusicListSucceeed {
    _sectionCount = 1;
    NSInteger defaultMid;
    //为了兼容修改的闹钟铃音
    if(_alarmClockTimerTypeFlag) defaultMid = _alarmClockSelectedMid;
    else defaultMid = [_gateway.default_music_index[_musicGroup] integerValue];
    
    _userGroup = [NSMutableArray arrayWithArray:[_gateway.music_list valueForKey:@"9"]];
    _gatewayGroup = [NSMutableArray arrayWithArray:[_gateway.music_list valueForKey:[NSString stringWithFormat:@"%ld",(long)_musicGroup]]];
//    _fileExistFlag = [_footerView recordFileExist];
    _fileExistFlag =  [self.recordVC recordFileExist];
    
    if(_fileExistFlag) _sectionCount ++;
    if(_userGroup.count) _sectionCount ++;
    
    _selectedSection = 0;
    for(int i = 0 ; i < _gatewayGroup.count ; i++){
        if([[_gatewayGroup[i] valueForKey:@"mid"] integerValue] == defaultMid){
            _selectedRow = i;
            _selectedSection = _sectionCount;
        }
    }
    
    if(_selectedSection != _sectionCount){
        for(int i = 0 ; i < _userGroup.count ; i ++){
            if([[_userGroup[i] valueForKey:@"mid"] integerValue] == defaultMid){
                _selectedRow = i;
                _selectedSection = _sectionCount - 1;
            }
        }
    }
    
    _selectedSection = _selectedSection - 1;
    
    [_tableView reloadData];
    if (_selectedRow >= 0 && _selectedSection >= 0){
        _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:_selectedSection];
        [_tableView cellForRowAtIndexPath:_selectedIndexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [_tableView scrollToRowAtIndexPath:_selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    //修改选取铃音的名字
    if (self.onSelectMusic) {
        NSString *musicname = [MHDeviceGateway getBellNameOfGroup:(BellGroup)_musicGroup index:_selectedRow];
        if (defaultMid > 1000) musicname = [_gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%ld",(long)defaultMid]];
        
        self.onSelectMusic(musicname);
        if (self.onSelectIndex)self.onSelectIndex(defaultMid);
    }
}

- (void)onSetMusicOfGroupSucceed:(NSInteger)groupIndex andSection:(NSInteger)section mid:(NSString *)mid {
    
    [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:_selectedSection]].accessoryType = UITableViewCellAccessoryNone;
    [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:groupIndex inSection:section]].accessoryType = UITableViewCellAccessoryCheckmark;
    _selectedRow = groupIndex;
    _selectedSection = section;
    
    NSInteger vol = _gateway.doorbell_volume;
    if(_musicGroup == 0) vol = _gateway.alarming_volume;
    if(_musicGroup == 1) vol = _gateway.doorbell_volume;
    if(_musicGroup == 2) vol = _gateway.gateway_volume;
    
    [_gateway playMusicWithMid:mid volume:vol Success:nil failure:nil];
    _gateway.default_music_index[_musicGroup] = mid;
    
    
    //修改选取铃音的名字
    if (self.onSelectMusic) {
        NSString *musicname = [MHDeviceGateway getBellNameOfGroup:(BellGroup)_musicGroup index:_selectedRow];
        if ([mid integerValue] > 1000) musicname = [self.gateway fetchGwDownloadMidName:mid];
        
        self.onSelectMusic(musicname);
        if (self.onSelectIndex)self.onSelectIndex([mid integerValue]);
    }
}

#pragma mark - DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _sectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 && [self.recordVC recordFileExist]) return 1;
    else if ((_sectionCount == 2 && !_fileExistFlag && section == 0) || (_sectionCount == 3 && section ==1) ) return _userGroup.count;
    else return _gatewayGroup.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(_sectionCount == 2){
        if(_fileExistFlag && section == 0) return NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.files",@"plugin_gateway", nil);
        else if(!_fileExistFlag && section == 0) return NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles",@"plugin_gateway", nil);
    }
    else if(_sectionCount == 3){
        if(section ==0 ) return NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.files",@"plugin_gateway", nil);
        if(section ==1 ) return NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles",@"plugin_gateway", nil);
    }
    return NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.gateway.bells",@"plugin_gateway", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"cell";
    MHDeviceSettingDefaultCell* cell = (MHDeviceSettingDefaultCell* )[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHDeviceSettingDefaultCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    __weak typeof(self) weakSelf = self;
    if(indexPath.section == 0 && _fileExistFlag){
        NSDictionary *attributes = [self.recordVC fileAttributes];
        
        _bellChooseCell = (MHGatewayBellChooseCell *)[tableView dequeueReusableCellWithIdentifier:BellChooseCellId];
        [_bellChooseCell configureWithDataObject:attributes];
        _bellChooseCell.uploadPressed = ^(MHGatewayBellChooseCell *detailCell){
//            [weakSelf.footerView upload];
            [weakSelf.recordVC upload];
        };
        return _bellChooseCell;
    }
    else if ((_sectionCount == 2 && !_fileExistFlag && indexPath.section == 0) || (_sectionCount == 3 && indexPath.section ==1) ){
        
        MHSafeDictionary* music = [MHSafeDictionary dictionaryWithDictionary:_userGroup[indexPath.row]];
        
        NSString *name = [self.gateway fetchGwDownloadMidName:[[music objectForKey:@"mid" class:[NSNumber class]] stringValue]];
        
        if(!name) name = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles",@"plugin_gateway", nil);
        NSDictionary *fileinfo = @{@"alias_name":name,@"time":[music objectForKey:@"time" class:[NSNumber class]]};
        
        MHGatewayUserDefineCell *userDefineCell = (MHGatewayUserDefineCell *)[tableView dequeueReusableCellWithIdentifier:UserDefinedCellId];
        [userDefineCell configureWithDataObject:fileinfo];
        userDefineCell.accessoryType = UITableViewCellAccessoryNone;
        
        if  (_selectedIndexPath == indexPath ) userDefineCell.accessoryType = UITableViewCellAccessoryCheckmark;
        return userDefineCell;
    }
    else{
        NSString* text = nil;
        NSString* detailText = nil;
        if (indexPath.row < [_gatewayGroup count]) {
            MHSafeDictionary* music = _gatewayGroup[indexPath.row];
            text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)_musicGroup index:indexPath.row];
            
            NSUInteger min = 0;
            NSUInteger sec = 0;
            NSUInteger seconds = [[music objectForKey:@"time" class:[NSNumber class]] unsignedIntegerValue];
            if (seconds >= 60 && seconds < 3600) {
                min = seconds / 60;
                sec = seconds % 60;
            } else if (seconds < 60) {
                sec = seconds;
            } else {
                min = 59;
                sec = 59;
                assert(0);  //超过1小时暂时不支持显示
            }
            detailText = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)min, (unsigned long)sec];
        }
        
        MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
        item.caption = text;
        //        item.comment = detailText;
        item.type = MHDeviceSettingItemTypeDefault;
        item.customUI = YES;
        item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        [cell fillWithItem:item];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        if  (_selectedIndexPath == indexPath ) cell.accessoryType = UITableViewCellAccessoryCheckmark;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.section == 0 && [self.recordVC recordFileExist]){
        //点击播放
        if(!_timer){
            [self.recordVC play];
            [self playAnimation:tableView andIndex:indexPath];
        }
    }
    else if ((_sectionCount == 2 && !_fileExistFlag && indexPath.section == 0) || (_sectionCount == 3 && indexPath.section ==1) ){
        MHSafeDictionary *music = _userGroup[indexPath.row];
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
        
        XM_WS(weakself);
        [_gateway setDefaultSoundWithGroup:_musicGroup musicId:[music objectForKey:@"mid" class:[NSString class]] Success:^(id obj){
            weakself.selectedIndexPath = indexPath;
            [weakself onSetMusicOfGroupSucceed:indexPath.row andSection:indexPath.section mid:[music objectForKey:@"mid" class:[NSString class]]];
            [[MHTipsView shareInstance] hide];
            
        } failure:^(NSError *error){
            [[MHTipsView shareInstance] hide];
        }];
    }
    else{
        XM_WS(weakself);
        MHSafeDictionary *music = _gatewayGroup[indexPath.row];
        [_gateway setDefaultSoundWithGroup:_musicGroup musicId:[music objectForKey:@"mid" class:[NSString class]] Success:^(id v) {
            weakself.selectedIndexPath = indexPath;
            [weakself onSetMusicOfGroupSucceed:indexPath.row andSection:indexPath.section mid:[music objectForKey:@"mid" class:[NSString class]]];
            [[MHTipsView shareInstance] hide];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
        }];
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && _fileExistFlag){
        if(editingStyle == UITableViewCellEditingStyleDelete) {
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.deleteconfirm",@"plugin_gateway", nil)  delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway",nil) otherButtonTitles:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway", nil), nil];
            action.tag = ACDeleteFile;
            [action showInView:self.view];
        }
    }
    else if ((_sectionCount == 2 && !_fileExistFlag && indexPath.section == 0) || (_sectionCount == 3 && indexPath.section ==1) ){
        if(editingStyle == UITableViewCellEditingStyleDelete) {
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.deleteconfirm",@"plugin_gateway", nil)  delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway",nil) otherButtonTitles:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway", nil), nil];
            action.tag = indexPath.row;
            [action showInView:self.view];
        }
    }
    else{
        if(editingStyle == UITableViewCellEditingStyleDelete) {
            [self.tableView reloadData];
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.gatewatdelete",@"plugin_gateway", nil) duration:1.5f modal:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && _fileExistFlag){}
    else if ((_sectionCount == 2 && !_fileExistFlag && indexPath.section == 0) || (_sectionCount == 3 && indexPath.section ==1) ){}
    else [self.tableView reloadData];
}

#pragma mark - 播放动画
-(void)playAnimation:(UITableView *)tableView andIndex:(NSIndexPath *)indexPath{
    
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(reloadTableView)];
    NSInvocation *invoker = [NSInvocation invocationWithMethodSignature:sig];
    [invoker setTarget:self];
    [invoker setSelector:@selector(reloadTableView)];
    [invoker retainArguments];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 invocation:invoker repeats:YES];
    [_timer fire];
}

-(void)reloadTableView{
    //这里用imageview animationImages 不管用，所以暂时用这个方法了。
    NSString *playImageName = @"lumi_gateway_audio";
    
    if(_imageTmpIndex == 0){
        _imageTmpIndex = 1;
        NSString *imageName = [NSString stringWithFormat:@"%@%d",playImageName,_imageTmpIndex];
        _bellChooseCell.imageView.image = [UIImage imageNamed:imageName];
    }
    else if(_imageTmpIndex == 1 || _imageTmpIndex == 2){
        _imageTmpIndex = _imageTmpIndex + 1;
        NSString *imageName = [NSString stringWithFormat:@"%@%d",playImageName,_imageTmpIndex];
        _bellChooseCell.imageView.image = [UIImage imageNamed:imageName];
    }
    else if(_imageTmpIndex == 3) {
        NSString *imageName = [NSString stringWithFormat:@"%@%d",playImageName,_imageTmpIndex];
        _bellChooseCell.imageView.image = [UIImage imageNamed:imageName];
        _imageTmpIndex = _imageTmpIndex - 3;
    }
}

-(void)stopAnimation{
    [_timer invalidate];
    _timer = nil;
    _bellChooseCell.imageView.image = [UIImage imageNamed:@"lumi_gateway_audio3"];
}

#pragma mark - action sheet deleget
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
        switch (buttonIndex) {
            case 0:
                if (actionSheet.tag == ACDeleteFile) [self deleteFile];
                else [self deleteGatewayDownloadFile:actionSheet.tag];
                
                break;
            default:
                break;
        }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
        }
            break;
        case 1: {
            [self onRecord];
        }
            break;
        case 2: {
            [self onFmPlayer];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 删除文件
-(void)deleteFile{
    __weak typeof(self) weakSelf = self;
    
    if ([self.recordVC removeFile:nil]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.center = CGPointMake(-cell.frame.size.width / 2, cell.center.y);
                         }
                         completion:^(BOOL finished) {
                             [weakSelf onGetMusicListSucceeed];
                         }];
    }
}

-(void)deleteGatewayDownloadFile:(NSInteger)index{
    //删除网关
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
    __weak typeof(self) weakSelf = self;
    
    MHSafeDictionary *music = _userGroup[index];
    [_gateway deleteUserMusicWithMid:[music objectForKey:@"mid" class:[NSString class]] success:^(id obj){
        //网关删除成功后删除配置文件
        NSInteger section = 0;
        if(weakSelf.fileExistFlag) section = 1;
        else section = 0;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.center = CGPointMake(-cell.frame.size.width / 2, cell.center.y);
                         }
                         completion:^(BOOL finished) {
                             [weakSelf deleteDownloadListPdata:[[weakSelf.userGroup[index] valueForKey:@"mid"] integerValue]];
                             
                             [weakSelf.userGroup removeObjectAtIndex:index];
                             [weakSelf.gateway.music_list setObject:weakSelf.userGroup forKey:@"9"];
                             [self onGetMusicListSucceeed];
                         }];
        
        [[MHTipsView shareInstance] hide];
        
    } failure:^(NSError *error){
        [[MHTipsView shareInstance] hide];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
}

#pragma mark - 设置网关下载音乐的列表
-(BOOL)setGatewayDownloadList
{
    //重新匹配列表，并设置
    NSMutableArray *extraDownlistData = [NSMutableArray arrayWithCapacity:1];
    for(NSDictionary *obj in _gateway.downloadMusicList){
        [extraDownlistData addObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"mid"]]];
    }
    
    NSMutableArray *currentList = [NSMutableArray arrayWithCapacity:1];
    for(NSDictionary *obj in self.userGroup){
        [currentList addObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"mid"]]];
    }
    
    [extraDownlistData removeObjectsInArray:[currentList mutableCopy]];
    
    if(extraDownlistData.count > 0){
        NSMutableArray *downlist = [_gateway.downloadMusicList mutableCopy];
        
        for(id mid in extraDownlistData){
            for(NSDictionary *obj in _gateway.downloadMusicList){
                if([[obj objectForKey:@"mid"] integerValue] == [mid integerValue])
                    [downlist removeObject:obj];
            }
        }
        
        //设置
        [_invoker setGatwayDownloadListWithValue:[downlist mutableCopy] Success:nil andFailure:nil];
    }
    
    return NO;
}

-(void)deleteDownloadListPdata:(NSInteger)mid
{
    NSMutableArray *downlist = [_gateway.downloadMusicList mutableCopy];
    for(NSDictionary *obj in _gateway.downloadMusicList){
        if([[obj objectForKey:@"mid" ] integerValue] == mid)
            [downlist removeObject:obj];
    }
    [_invoker setGatwayDownloadListWithValue:[downlist mutableCopy] Success:nil andFailure:nil];
}

-(void)getGatewayDownloadList
{
    XM_WS(weakself);
    _invoker =[[MHGwMusicInvoker alloc] initWithDevice:_gateway];
    [_invoker readGatwayDownloadListWithSuccess:^(id v){
        [weakself.tableView reloadData];
    } andFailure:nil];
}

@end
