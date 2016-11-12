//
//  MHIFTTTACCustomMusicViewController.m
//  MiHome
//
//  Created by ayanami on 16/8/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHIFTTTACCustomMusicViewController.h"
#import "MHIFTTTManager.h"
#import "MHIFTTTMusicChooseNewViewController.h"

#define kACPARTNER_Music_ACTIONID   @"305"

@interface MHIFTTTACCustomMusicViewController ()

@property (nonatomic,strong) MHIFTTTMusicChooseNewViewController *musicListView;

@property (nonatomic,assign) NSInteger selectedMid;
@property (nonatomic,assign) NSInteger selectedVolume;

@end


@implementation MHIFTTTACCustomMusicViewController
+ (void)load {
    
    [MHIFTTTManager registerActionCustomViewController:self actionId:kACPARTNER_Music_ACTIONID];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;
    
    //    NSLog(@"%@", NSStringFromClass([self.device class]));
    //    NSLog(@"%@", self.device);
    //    [MHDevFactory deviceFromModelId:newDevice.model dataDevice:newDevice];
    //    NSLog(@"%@", self.acpartner.did);
    
//    NSLog(@"自动化中的空调type<<%d>>", self.acpartner.ACType);
    
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.control",@"plugin_gateway","播放指定铃音");
//    if ([self.action.actionId isEqualToString:kACPARTNER_FM_ACTIONID]) {
//        self.title = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.fm.title", @"plugin_gateway", nil);
//    }
    
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
    NSInteger group = 1 ;
    if([self.action.actionId isEqualToString:kACPARTNER_Music_ACTIONID]) group = 9;
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

- (void)onDone:(id)sender {
    if (_selectedMid != -1){
        NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:self.action.payload];
       
        if ([self.action.actionId isEqualToString:kACPARTNER_Music_ACTIONID]){
            NSString *strMid = [NSString stringWithFormat:@"%ld", (long)_selectedMid];
            NSMutableArray *valueStr = [NSMutableArray arrayWithObjects:strMid,@((long)_selectedVolume), nil];
            [payload setObject:valueStr forKey:@"value"];
        }
        if(self.completionHandler)self.completionHandler(payload);
        [self onBack:nil];
    }
    else {
        NSString *tips = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.choosetips", @"plugin_gateway", nil);
        [[MHTipsView shareInstance] showFailedTips:tips duration:1.5 modal:NO];
    }
}

- (void)onBack:(id)sender {
    [(MHDeviceGateway *)self.device setSoundPlaying:@"off" success:nil failure:nil];
    [super onBack:sender];
}

@end
