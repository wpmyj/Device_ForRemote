//
//  MHIFTTTGatewayCustomizeViewController.m
//  MiHome
//
//  Created by Lynn on 1/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHIFTTTGatewayCustomizeViewController.h"
#import "MHIFTTTManager.h"
#import "MHIFTTTLmCustomizeManager.h"
#import "MHIFTTTMusicChooseViewController.h"
#import "MHIFTTTFMChooseViewController.h"
#import "MHIFTTTMusicChooseNewViewController.h"

@interface MHIFTTTGatewayCustomizeViewController ()

//@property (nonatomic,strong) MHIFTTTMusicChooseViewController *musicListView;

@property (nonatomic,strong) MHIFTTTMusicChooseNewViewController *musicListView;

@property (nonatomic,strong) MHIFTTTFMChooseViewController *fmListView;
@property (nonatomic,assign) NSInteger selectedMid;
@property (nonatomic,assign) NSInteger selectedVolume;

@end

@implementation MHIFTTTGatewayCustomizeViewController
{
    NSString *              _keyType;
}

+ (void)load {
    [MHIFTTTManager registerCustomViewControllerClass:self forModel:@"lumi.gateway.v3" plugId:Gateway_PlugInID];
//    [MHIFTTTManager registerActionCustomViewController:self actionId:(NSString *)]
}

- (void)viewDidLoad {
    _selectedMid = -1;
    
    if(self.action) {
        _keyType =[[MHIFTTTLmCustomizeManager sharedInstance] fetchSpecificActionCommand:self.action];
    }
    
    if ([_keyType isEqualToString:Gateway_IFTTT_PlayMusic]) {
        self.title = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.title", @"plugin_gateway", nil);
    }
    if ([_keyType isEqualToString:Gateway_IFTTT_DoorBell]) {
        self.title = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.doorbell.title", @"plugin_gateway", nil);
    }
    if ([_keyType isEqualToString:Gateway_IFTTT_PlayFm]) {
        self.title = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.fm.title", @"plugin_gateway", nil);
    }
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.isNavBarHidden = NO;
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(0, 0, 46, 26);
    [confirmBtn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [confirmBtn setTitle:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定") forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    confirmBtn.layer.cornerRadius = 3.0f;
    [confirmBtn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmBtn];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    XM_WS(weakself);
    if ([_keyType isEqualToString:Gateway_IFTTT_DoorBell] || [_keyType isEqualToString:Gateway_IFTTT_PlayMusic]) {
        NSInteger group = 1 ;
        if([_keyType isEqualToString:Gateway_IFTTT_PlayMusic]) group = 9;
        _musicListView = [[MHIFTTTMusicChooseNewViewController alloc] initWithGateway:(MHDeviceGateway *)self.device musicGroup:group];
//        _musicListView = [[MHIFTTTMusicChooseViewController alloc] initWithGateway:(MHDeviceGateway *)self.device musicGroup:group];

        _musicListView.onSelectMusicMid = ^(NSInteger mid){
            weakself.selectedMid = mid;
        };
        _musicListView.onSelectMusicVolume = ^(NSInteger volume){
            weakself.selectedVolume = volume;
        };
        [self.view addSubview:_musicListView.view];
    }
    
    if ([_keyType isEqualToString:Gateway_IFTTT_PlayFm]) {
        _fmListView = [[MHIFTTTFMChooseViewController alloc] initWithGateway:(MHDeviceGateway *)self.device];
        _fmListView.onSelectMusicMid = ^(NSInteger mid){
            weakself.selectedMid = mid;
        };
        _fmListView.onSelectMusicVolume = ^(NSInteger volume){
            weakself.selectedVolume = volume;
        };
        [self.view addSubview:_fmListView.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onDone:(id)sender {
    if (_selectedMid != -1){
        NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:self.action.payload];
        if ([_keyType isEqualToString:Gateway_IFTTT_DoorBell]){
            [payload setObject:@(_selectedMid) forKey:@"value"];
        }
        if ([_keyType isEqualToString:Gateway_IFTTT_PlayMusic]){
            NSString *strMid = [NSString stringWithFormat:@"%ld", (long)_selectedMid];
            NSMutableArray *valueStr = [NSMutableArray arrayWithObjects:strMid,@((long)_selectedVolume), nil];
            [payload setObject:valueStr forKey:@"value"];
        }
        if ([_keyType isEqualToString:Gateway_IFTTT_PlayFm]){
            NSArray *fmValueStr = [NSArray arrayWithObjects:@((long)_selectedMid),@((long)_selectedVolume), nil];
            [payload setObject:fmValueStr forKey:@"value"];
        }
        if(self.completionHandler)self.completionHandler(payload);
        [self onBack:nil];
    }
    else {
        NSString *tips = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.choosetips", @"plugin_gateway", nil);
        if ([_keyType isEqualToString:Gateway_IFTTT_PlayFm]) {
            tips = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.fm.choosetips", @"plugin_gateway", nil);
        }
        [[MHTipsView shareInstance] showFailedTips:tips duration:1.5 modal:NO];
    }
}

- (void)onBack:(id)sender {
    [(MHDeviceGateway *)self.device setSoundPlaying:@"off" success:nil failure:nil];
    [super onBack:sender];
}

@end
