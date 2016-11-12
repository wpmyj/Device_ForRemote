//
//  MHGatewayFMControlView.m
//  MiHome
//
//  Created by guhao on 2/22/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayFMControlView.h"
#import "MHLumiFMVolumeControl.h"
#import "MHLumiXMDataManager.h"
#import "MHLumiFMCollectionInvoker.h"
#import "MHGatewayOfflineManager.h"
@interface MHGatewayFMControlView ()

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *volumeBtn;
@property (nonatomic, strong) UILabel *radioTitle;
@property (nonatomic, strong) UILabel *TipsTitle;

@property (nonatomic, strong) MHLumiFMCollectionInvoker *invoker;
@property (nonatomic, strong) MHDeviceGateway *radioDevice;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation MHGatewayFMControlView


- (instancetype)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway
{
    self = [super initWithFrame:frame];
    if (self) {
        /*
         @property (nonatomic,strong) MHDeviceGateway *radioDevice;
         @property (nonatomic,strong) MHLumiXMRadio *currentRadio;
         @property (nonatomic,strong) NSString *currentProgramName;
         @property (nonatomic,assign) BOOL isHide;
         @property (nonatomic,assign) BOOL isPlaying;
         @property (nonatomic,strong) NSMutableArray *radioPlayList;
         */
//        [self setRadioDevice:gateway];
        _radioDevice = gateway;
        _invoker = [[MHLumiFMCollectionInvoker alloc] init];
        _invoker.radioDevice = _radioDevice;
        
        [self buildSubViews];
        //获取收藏电台缓存表
        [self firstRestoreData];
        
        //获取网关播放信息
        [self fetchRadioDeviceStatus];
        
        
        //获取收藏
        XM_WS(weakself);
        [[MHLumiXMDataManager sharedInstance] restoreCollectionRadioDeviceDid:_radioDevice.did
                                                                   withFinish:^(NSMutableArray *datalist){
                                                                       [weakself showReceivedData:datalist];
                                                                   }];
        
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}

- (void)dealloc {
    
}

- (void)buildSubViews {
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn addTarget:self action:@selector(onPlay:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setImage:[UIImage imageNamed:@"mainpage_lumi_fm_play_big"] forState:UIControlStateNormal];
    [self addSubview:_playBtn];
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setImage:[UIImage imageNamed:@"lumi_fm_next_big"] forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(onNextParagrame:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nextBtn];
    
    _volumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_volumeBtn setImage:[UIImage imageNamed:@"lumi_fm_player_volum_mini"] forState:UIControlStateNormal];
    [_volumeBtn addTarget:self action:@selector(onVolume:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_volumeBtn];
    
    _radioTitle = [[UILabel alloc] init];
    _radioTitle.textAlignment = NSTextAlignmentCenter;
    _radioTitle.font = [UIFont systemFontOfSize:16.0f];
    _radioTitle.textColor = [UIColor whiteColor];
    [self addSubview:_radioTitle];
    
    _TipsTitle = [[UILabel alloc] init];
    _TipsTitle.textAlignment = NSTextAlignmentCenter;
    _TipsTitle.font = [UIFont systemFontOfSize:14.0f];
    _TipsTitle.textColor = [UIColor whiteColor];
    [self addSubview:_TipsTitle];
    
    XM_WS(weakself);
    self.fmPlayer = [MHLumiFmPlayer shareInstance];
    self.fmPlayer.radioDevice = _radioDevice;
    self.fmPlayer.playCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself showFmPlayer:currentRadio];
    };
    self.fmPlayer.controlCallBack = ^(BOOL isPlaying){
        [weakself playeIsON:isPlaying];
    };
    self.fmPlayer.pauseCallBack = ^(MHLumiXMRadio *currentRadio){
        [weakself showFmPlayer:currentRadio];
    };
//    _fmPlayer.isHide = YES;
    
    MHLumiXMRadio *tmpRadio = [[MHLumiXMRadio alloc] init];
    tmpRadio.radioName = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.noneradio", @"plugin_gateway", nil);
    [self showFmPlayer:tmpRadio];

}

- (void)buildConstraints {
    CGFloat playBtnSize = 156 * ScaleHeight;
    CGFloat nextBtnSize = 71 * ScaleHeight;
    CGFloat radioTitleSpacing = 80 * ScaleHeight;
    CGFloat playBtnSpacing = 50 * ScaleHeight;
    CGFloat spacing = 5;
    CGFloat herizonSpacing = 20 * ScaleWidth;
    
    XM_WS(weakself);
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.centerY.mas_equalTo(weakself.mas_centerY).with.offset(-playBtnSpacing);
        make.size.mas_equalTo(CGSizeMake(playBtnSize, playBtnSize));
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.playBtn);
        make.left.mas_equalTo(weakself.playBtn.mas_right).with.offset(herizonSpacing);
        make.size.mas_equalTo(CGSizeMake(nextBtnSize, nextBtnSize));
    }];
    
    
    [self.volumeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.playBtn);
        make.right.mas_equalTo(weakself.playBtn.mas_left).with.offset(-herizonSpacing);
        make.size.mas_equalTo(CGSizeMake( nextBtnSize, nextBtnSize));
    }];
    
    [self.radioTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.bottom.equalTo(weakself).with.offset(-radioTitleSpacing);
    }];
    
    [self.TipsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.radioTitle.mas_bottom).with.offset(spacing);
    }];
    
    
}
#pragma mark - 数据操作
- (void)firstRestoreData {
    //获取收藏电台缓存表
    XM_WS(weakself);
    [_invoker mainPageFetchCollectionListWithSuccess:^(NSMutableArray *datalist) {
        [weakself showReceivedData:datalist];
    } andFailure:^(NSError *error) {
        
    }];
}

- (void)showReceivedData:(NSMutableArray *)datalist {
    NSLog(@"获取的电台列表%@", datalist);
    self.dataSource = [NSMutableArray arrayWithArray:datalist];
    self.fmPlayer.radioPlayList = self.dataSource;
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
                weakself.fmPlayer.isPlaying = weakself.radioDevice.current_status;
                [weakself playeIsON:weakself.radioDevice.current_status];
            }
            if(radioId) {
                [weakself fetchRadioDetailInfo:radioId];
            }
        }
        
    } andFailure:^(NSError *error) {
        NSLog(@"%@",error);
        if (self.dataSource.count) {
            weakself.fmPlayer.currentRadio = self.dataSource.firstObject;
            [weakself showFmPlayer:self.dataSource.firstObject];
        }
    }];
}

//获取当前节目详情(第一次进入)
- (void)fetchRadioDetailInfo:(NSString *)radioId {
    
    XM_WS(weakself);
    
    MHLumiXMDataManager *manager = [MHLumiXMDataManager sharedInstance];
    [manager fetchRadioByIds:@[ radioId ] withSuccess:^(NSArray *radiolist) {
        
        MHLumiXMRadio *rawRadio = radiolist.firstObject;
        
        [weakself showFmPlayer:rawRadio];
        weakself.fmPlayer.currentRadio = rawRadio;
        weakself.fmPlayer.radioPlayList = weakself.dataSource;
        
        
    } failure:^(NSError *error) {
    }];
}
- (void)showFmPlayer:(id)radio {
    self.fmPlayer.currentRadio = radio;
      self.fmPlayer.radioPlayList = self.dataSource;
    [self playeIsON:self.fmPlayer.isPlaying];
    [self updatePrograms:radio];
}

- (void)updatePrograms:(id)radio {
    NSString *radioName = [radio valueForKey:@"radioName"];
    _radioTitle.text =  radioName ? [NSString stringWithFormat:@"%@>" ,radioName] : [NSString stringWithFormat:@"%@>" ,NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.noneradio", @"plugin_gateway", nil)];
    _TipsTitle.text = [radio valueForKey:@"currentProgram"];
}

- (void)playeIsON:(BOOL)isPlayer {
    [_playBtn setImage:[UIImage imageNamed: isPlayer ? @"mainpage_lumi_fm_pause_big" : @"mainpage_lumi_fm_play_big" ] forState:UIControlStateNormal];
}

#pragma mark - 控制
//调音量
- (void)onVolume:(id)sender {
    [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:self.radioDevice];
    
    MHLumiFMVolumeControl *volumeControl = [MHLumiFMVolumeControl shareInstance];
    volumeControl.gateway = _radioDevice;
    [volumeControl showVolumeControl:CGRectGetMaxY(self.window.bounds) - VolumePlayerHeight withVolumeValue:_radioDevice.fm_volume];
    
    XM_WS(weakself);
    volumeControl.volumeControlCallBack = ^(NSInteger value){
        
        [weakself.fmPlayer setDeviceFMVolume:value withSuccess:^(id obj) {
            if ([[obj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
                weakself.radioDevice.fm_volume = [[[obj valueForKey:@"result"] valueForKey:@"volume"] integerValue];
            }
        } failure:nil];
    };

}
//下一首
- (void)onNextParagrame:(id)sender {
    [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:self.radioDevice];

//    [[MHTipsView shareInstance] showTips:@"今天没吃药感觉萌萌哒" modal:NO];

    if (!self.dataSource.count) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.collection.nonelist", @"plugin_gateway", "没有收藏哦,请先添加收藏") duration:1.5f modal:NO];
        return;
    }
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:YES];
    NSInteger currentIdx = [self.fmPlayer.radioPlayList indexOfObject:self.fmPlayer.currentRadio];
    NSInteger nextIdx = currentIdx + 1;
    
    if(currentIdx >= self.fmPlayer.radioPlayList.count - 1){
        nextIdx = 0;
    }
    self.fmPlayer.currentRadio = self.fmPlayer.radioPlayList[nextIdx];
    
    [self fetchRadioDetailInfo:self.fmPlayer.currentRadio.radioId];
    [self.fmPlayer play];
}
//开关
- (void)onPlay:(id)sender {

//    [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:self.radioDevice];
    
    
    NSLog(@"播放前的fm数据%@", self.dataSource);
    if(self.fmPlayer.isPlaying){
//        self.fmPlayer.isPlaying = NO;
//        
//        [self.radioDevice playRadioWithMethod:@"off" andSuccess:^(id obj){
//            [weakself playeIsON:NO];
//        } andFailure:^(NSError *error){
//            weakself.fmPlayer.isPlaying = YES;
//            [weakself playeIsON:YES];
//        }];
        [self.fmPlayer pause];
        [self playeIsON:NO];
    }
    else{
        if (!self.dataSource || !self.dataSource.count) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.collection.nonelist", @"plugin_gateway", "没有收藏哦,请先添加收藏") duration:1.5f modal:NO];
            return;
        }
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:YES];
        [self.fmPlayer play];
        [self playeIsON:YES];
    }
}
#pragma mark - 更新状态 
- (void)updateStastus {
    NSLog(@"首页的fmplayer数据%ld", self.fmPlayer.radioPlayList.count);
    //获取网关播放信息
    [self firstRestoreData];
    [self fetchRadioDeviceStatus];
}



@end
