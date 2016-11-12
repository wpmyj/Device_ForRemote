//
//  MHGatewayCloudMusicViewController.m
//  MiHome
//
//  Created by Lynn on 8/31/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayCloudMusicViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHGatewayMusicListManager.h"
#import "MHDeviceSettingCheckCell.h"
#import "MHTableViewControllerInternal.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMediaQuery.h>
#import "MHGwMusicInvoker.h"

#define RowHeight 55.f

@interface MHGatewayCloudMusicViewController () <UITableViewDelegate,UITableViewDataSource, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic,strong) NSMutableArray* musicList;
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong) AVAudioPlayer* audioplayer;
@property (nonatomic,strong) NSNumber*  freeSpace;
@property (nonatomic,strong) NSMutableArray* hasDownloadMusicList;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) MHGwMusicInvoker* musicVoker;
@property (nonatomic,strong) NSMutableArray* gatewayUserMusicList;
@property (nonatomic,strong) MHSafeDictionary* hasSelectMusic;

@end

@implementation MHGatewayCloudMusicViewController{
    MHDeviceGateway*        _gateway;
    UITableView*            _tableViewLocal;
    UISegmentedControl*     _segmentedControl;
    NSString*               _selectedMid;
    NSString*               _selectedUrl;
    NSInteger               _selectedSize;
    NSURL*                  _downloadMusicDirectory;
    int                     _currentPage;
    BOOL                    _stopGetMore;
    int                     _totalPage;
}
@synthesize musicList = _musicList;

- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        _gateway = gateway;
        _selectedMid=nil;
        _selectedUrl=nil;
        [self initDownloadMusicDirectory];
        
    }
    return self;
}

- (void)applicationWillEnterForeground {
    
    _hasDownloadMusicList=[[NSMutableArray alloc] init];
    if(_gateway){
            typeof(self) __weak weakSelf = self;
        [_gateway getMusicFreespaceSuccess:^(id result){
            NSMutableDictionary* json=[result valueForKey:@"result"];
            weakSelf.freeSpace=[json objectForKey:@"FreeSpace"];
            
        } failure:^(NSError*v){
        }];
        self.musicVoker=[[MHGwMusicInvoker alloc] initWithDevice:_gateway];
        [self.musicVoker readGatwayDownloadListWithSuccess:^(id result){
            weakSelf.gatewayUserMusicList=[[NSMutableArray alloc] initWithArray:result];
        
        } andFailure:^(NSError* error){
        
        }];
        
        if([_gateway.music_list objectForKey:[NSString stringWithFormat:@"%d",9]]){
           NSMutableArray* list = [NSMutableArray arrayWithArray:[_gateway.music_list objectForKey:@"9"]];
            for (int i=0; i<list.count; i++) {
                NSMutableDictionary* music=[list objectAtIndex:i];
                NSString* a=[music objectForKey:@"mid"];
                [weakSelf.hasDownloadMusicList addObject:a];
            }
            [self.tableView reloadData];
        }else{
             typeof(_gateway) __weak gatewayWeakSelf = _gateway;
            [_gateway getMusicInfoWithGroup:0 Success:^(id result){
                
                if([gatewayWeakSelf.music_list objectForKey:[NSString stringWithFormat:@"%d",9]]){
                    self.hasDownloadMusicList=[gatewayWeakSelf.music_list objectForKey:[NSString stringWithFormat:@"%d,",9]];}
                [weakSelf.tableView reloadData];
                
            } failure:^(NSError* error){
            }];
        }
    }
}

- (void)applicationDidEnterBackground {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

- (void)initDownloadMusicDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *caches = [fileManager URLsForDirectory: NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL* homeCache=[caches objectAtIndex:0];
    _downloadMusicDirectory=[homeCache URLByAppendingPathComponent:@"com/lumi/gateway/download/music"];
    if(![fileManager fileExistsAtPath:_downloadMusicDirectory.path]){
    [fileManager createDirectoryAtURL:_downloadMusicDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)setMusicList:(NSMutableArray *)musicList {
    if(_musicList != musicList){
        _musicList = musicList;
        [_tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.musicList = [NSMutableArray arrayWithArray:_gateway.initialMusicList];
    _currentPage = 0;
    [self getCloudMusic:_currentPage];
    [self applicationWillEnterForeground];
}


- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

    return session;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _tableView.delegate = nil;
    _tableView = nil;
    _tableViewLocal.delegate = nil;
    _tableViewLocal = nil;
}


- (void)buildSubviews {
    [super buildSubviews];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 26);
    [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway",  "确定") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn.layer.cornerRadius = 3.0f;
    [btn addTarget:self action:@selector(onSure:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    _segmentedControl = [[UISegmentedControl alloc ]initWithItems:@[@"在线",@"本地"]];
    _segmentedControl.frame = CGRectMake(0, 0, 160, 24);
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl addTarget:self action:@selector(changeLocal:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.title=NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.adder",@"plugin_gateway", "添加铃声");

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [MHColorUtils colorWithRGB:0xE1E1E1];
    [self.view addSubview:_tableView];
    _tableViewLocal = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableViewLocal.delegate = self;
    _tableViewLocal.dataSource = self;
    _tableViewLocal.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableViewLocal.separatorColor = [MHColorUtils colorWithRGB:0xE1E1E1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -check local tab
- (void)changeLocal:(UISegmentedControl *)Seg {
    if([_segmentedControl selectedSegmentIndex]==1){
        [self.view bringSubviewToFront:_tableViewLocal];
         [_tableViewLocal reloadData];
    }else{
        [self.view bringSubviewToFront:_tableView];
         [_tableView reloadData];
    }
    
}
#pragma mark -check sure button
- (void)onSure:(id)sender {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    if(_gateway){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.downloading",@"plugin_gateway",  @"正在更新...") modal:NO];
        
        typeof(self) __weak weakSelf = self;
        typeof(_gateway) __weak gatewayWeakSelf = _gateway;

        if(_selectedMid!=nil&&![_hasDownloadMusicList containsObject:_selectedMid]){
            [_gateway downloadUserMusicWithMid:_selectedMid url:_selectedUrl success:^(id v){
            [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.download.ok",@"plugin_gateway",  @"完成更新") duration:1.5 modal:NO];
                if(weakSelf.gatewayUserMusicList){
                    if(weakSelf.hasSelectMusic){
                        NSMutableDictionary* selectMusic=[[NSMutableDictionary alloc] init];
                        [selectMusic setObject:[weakSelf.hasSelectMusic objectForKey:@"mid"] forKey:@"mid"];
                        [selectMusic setObject:[weakSelf.hasSelectMusic objectForKey:@"mid"] forKey:@"name"];
                        [selectMusic setObject:[weakSelf.hasSelectMusic objectForKey:@"alias_name"] forKey:@"alias_name"];
                        [weakSelf.gatewayUserMusicList addObject:selectMusic];
                        weakSelf.musicVoker=[[MHGwMusicInvoker alloc] initWithDevice:gatewayWeakSelf];
                        [weakSelf.musicVoker setGatwayDownloadListWithValue:weakSelf.gatewayUserMusicList Success:^(id result){
                            if(weakSelf.returnStateBlock){
                                weakSelf.returnStateBlock(YES);
                            }
                            [weakSelf onBack:weakSelf];
                            
                        } andFailure:^(NSError* error){
                            if(weakSelf.returnStateBlock){
                                weakSelf.returnStateBlock(YES);
                            }
                            [weakSelf onBack:weakSelf];
                        }];
                                
                    }
                    else{
                        if(weakSelf.returnStateBlock){
                            weakSelf.returnStateBlock(YES);
                        }
                        [weakSelf onBack:weakSelf];
                    }
                }
                else{
                    if(weakSelf.returnStateBlock){
                        weakSelf.returnStateBlock(YES);
                    }
                    [weakSelf onBack:weakSelf];
                } 

            } failure:^(NSError* error){
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.download.fail",@"plugin_gateway",  @"更新失败") duration:1.5 modal:NO];
            }];
        }
        else{
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.be.in.gateway.nodownload" ,@"plugin_gateway",  @"请选择有效的音乐") duration:1.5 modal:NO];
        }
    }
}

#pragma mark - tableview load data
- (void)startRefresh {
    _currentPage = 0;
    [self getCloudMusic:_currentPage];
}

- (void)startGetmore {
    if(_currentPage + 1 <= _totalPage){
        _currentPage = _currentPage + 1;
        [self getCloudMusic:_currentPage];
    }
    
    if(_currentPage + 1 >= _totalPage){
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.loadfinished",@"plugin_gateway", "加载完毕") duration:1.5 modal:NO];
    }
}

#pragma mark - 获取云端音乐列表
- (void)getCloudMusic:(int)pageIndex {
    __weak typeof(self) weakSelf = self;
    
    MHGatewayMusicListManager *lisManager = [[MHGatewayMusicListManager alloc] init];
    [lisManager fetchMusicListWithPageIndex:pageIndex success:^(id obj){
        [weakSelf gotMusicListSuccess:obj];
        
    } andfailure:^(NSError *error){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.loadfailed",@"plugin_gateway", "加载失败") duration:1.5 modal:NO];
    }];
}

- (void)gotMusicListSuccess:(id)obj {
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:obj];
    NSMutableDictionary* pageInfo = tmpArray.lastObject;
    [tmpArray removeLastObject];
    
    int total = [[pageInfo valueForKey:@"total"] intValue];
    int size = [[pageInfo valueForKey:@"size"] intValue];
    _totalPage = total / size + (total % size ? 1 : 0);
    
    if(_currentPage != 0){
        [self.musicList addObjectsFromArray:tmpArray.mutableCopy];
        [_tableView reloadData];
        [_tableViewLocal reloadData];
    }
    else self.musicList = tmpArray;
    
    if (self.musicList.count * RowHeight <= self.view.bounds.size.height )
        [self startGetmore];
}

#pragma mark - UITableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_segmentedControl.selectedSegmentIndex==1){
        //在线获取的录音数量
        return 5;
    }else{
     return [self.musicList count];
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MHSafeDictionary* music = [MHSafeDictionary dictionaryWithDictionary:self.musicList[indexPath.row]];
    NSString*  url = [music objectForKey:@"url"];
    NSString* mid;
    if([[music objectForKey:@"mid"] isKindOfClass:[NSNumber class]]){
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        mid=[numberFormatter stringFromNumber:[music objectForKey:@"mid"]];
    }else{
        mid=[music objectForKey:@"mid"];
    }
    
    static NSString* cellIdentifier = @"cell";
    MHDeviceSettingCheckCell* cell = (MHDeviceSettingCheckCell* )[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHDeviceSettingCheckCell alloc] initWithReuseIdentifier:cellIdentifier];
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    
    NSString* text = nil;
    NSString* detailText = nil;
    
    if(_segmentedControl.selectedSegmentIndex==1){
 
    }else{
        if (indexPath.row < [self.musicList count]) {
            MHSafeDictionary* music = [MHSafeDictionary dictionaryWithDictionary:self.musicList[indexPath.row]];
            text = [music objectForKey:@"alias_name"];
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
            detailText = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
        }
    }
    
    MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
    item.caption = text;
    item.isOn=YES;
    item.comment = detailText;
    item.type = MHDeviceSettingItemTypeDefault;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    [cell fillWithItem:item];
    
    if([self isMusicHasDownloadToGateway:mid]){
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 62, 26);
        [btn setBackgroundColor:[MHColorUtils colorWithRGB:0xCCCCCC]];
        [btn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.be.in.gateway", @"plugin_gateway", "已存在") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        btn.layer.cornerRadius = 3.0f;
        cell.accessoryView=btn;
         cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else{
        BOOL checked =NO;
        if(_selectedMid!=nil){
            if([_selectedMid isEqualToString:mid]){
                checked=YES;
            }else{
                checked=NO;
            }
        }
        
        UIImage *image =(checked) ? [UIImage imageNamed:@"checkbox_checked.png"] : [UIImage imageNamed:@"checkbox_unchecked.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        button.frame = frame;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        
        cell.accessoryView = button;
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_segmentedControl.selectedSegmentIndex==1){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        MHDeviceSettingCheckCell* cell=[tableView cellForRowAtIndexPath:indexPath];
        cell.item.hasAcIndicator=YES;
        
        if (indexPath.row < [self.musicList count]) {
            MHSafeDictionary* music = [MHSafeDictionary dictionaryWithDictionary:self.musicList[indexPath.row]];
            NSString*  url = [music objectForKey:@"url"];
            NSUInteger size = [[music objectForKey:@"size" class:[NSNumber class]] unsignedIntegerValue];
            NSString* mid;
            if([[music objectForKey:@"mid"] isKindOfClass:[NSNumber class]]){
                NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                mid=[numberFormatter stringFromNumber:[music objectForKey:@"mid"]];
            }
            else{
                mid=[music objectForKey:@"mid"];
            }
            _selectedMid=mid;
            self.hasSelectMusic=music;
            _selectedUrl=url;
            NSURL *requestURL = [NSURL URLWithString:url];
            NSURL *musicFileUrl = [_downloadMusicDirectory URLByAppendingPathComponent:[requestURL lastPathComponent]];
            typeof(self) __weak weakSelf = self;
            if([[NSFileManager defaultManager] fileExistsAtPath:musicFileUrl.path]){
                self.audioplayer=[[AVAudioPlayer alloc]initWithContentsOfURL:musicFileUrl error:Nil];
                AVAudioSession * audioSession = [AVAudioSession sharedInstance];
                [audioSession setCategory:AVAudioSessionCategoryPlayback error: nil];
                [self.audioplayer prepareToPlay];
                [self.audioplayer play];
               
                [weakSelf.tableView reloadData];
            }
            else{
                static NSURLSession *session = nil;
                NSString *identiferHead=@"com.lumi.BackgroundSessionDownload";
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:[identiferHead stringByAppendingPathComponent:[[NSURL URLWithString:url] absoluteString]]];
                session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
                self.downloadTask = [session downloadTaskWithRequest:request];
                [self.downloadTask resume];
                [weakSelf.tableView reloadData];
            }
        }
    }
}

- (void)checkButtonTapped:(id)sender event:(id)event {

}

- (BOOL)isMusicHasDownloadToGateway:(NSString*)mid {
    if(_hasDownloadMusicList!=nil&&_hasDownloadMusicList.count>0){
        return [_hasDownloadMusicList containsObject:mid];
    }
    else{
        return NO;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [_downloadMusicDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    if([fileManager fileExistsAtPath:destinationURL.path]){
        [fileManager removeItemAtURL:destinationURL error:NULL];
    }
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
         typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            weakSelf.audioplayer=[[AVAudioPlayer alloc]initWithContentsOfURL:destinationURL error:Nil];
            AVAudioSession * audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error: nil];
            [weakSelf.audioplayer prepareToPlay];
            [weakSelf.audioplayer play];
        });
    }
}

#pragma mark - Scroll delegate
CGFloat _lastOffsizeY;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_segmentedControl.selectedSegmentIndex==1){
    }
    else{
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        if (_lastOffsizeY < contentOffsetY){
            CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
            if (maxOffsetY > 0 && contentOffsetY > maxOffsetY && !_stopGetMore) {
                _stopGetMore = YES;
                [self startGetmore];
            }
        }
        _lastOffsizeY = scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(_segmentedControl.selectedSegmentIndex==1){
    }
    else{
        if (!decelerate && _stopGetMore) {
            _stopGetMore = NO;
        }
    }
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_segmentedControl.selectedSegmentIndex==1){
    }
    else {
        if (_stopGetMore) {
            _stopGetMore = NO;
        }
    }
}

@end
