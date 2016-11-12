//
//  MHGatewayClockRecordViewController.m
//  MiHome
//
//  Created by guhao on 16/4/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayClockRecordViewController.h"
#import "MHGatewayRecordButtonView.h"
#import "MHMusicTipsView.h"

@interface MHGatewayClockRecordViewController ()

@property (nonatomic,strong)  MHGatewayRecordButtonView *footerView;
@property (nonatomic,strong)  MHDeviceGateway *gateway;

@end

@implementation MHGatewayClockRecordViewController

- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        _gateway = gateway;
        [self buildFooterView];
        self.isTabBarHidden = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)buildFooterView {
    
    XM_WS(weakself);
    _footerView = [[MHGatewayRecordButtonView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 68, CGRectGetWidth(self.view.bounds), 68) andType:AlarmClock_RecordFile];
    _footerView.gateway = _gateway;
    _footerView.backgroundColor = [UIColor whiteColor];
    _footerView.recordSuccess = ^(){
        [weakself gw_clickMethodCountWithStatType:@"recordSuccess"];
        if (weakself.recordSuccess) {
            weakself.recordSuccess();
        }
    };
    _footerView.playStoped = ^(){
        [weakself gw_clickMethodCountWithStatType:@"playStoped"];
        if (weakself.playStoped) {
            weakself.playStoped();
        }
    };
    _footerView.uploadSuccess = ^(NSDictionary *fileinfo){
        if (weakself.uploadSuccess) {
            weakself.uploadSuccess(fileinfo);
        }
    };
    _footerView.uploadProgress = ^(CGFloat progress){
        [[MHMusicTipsView shareInstance] setProgressCnt:progress];
    };
    _footerView.uploadStart = ^(CGFloat progress){
        [[MHMusicTipsView shareInstance] showProgressView:0.001 withTips:@"0.1%"];
    };
    [self.view addSubview:_footerView];
}

- (BOOL)recordFileExist {
    return [_footerView recordFileExist];
}

- (NSDictionary *)fileAttributes {
    return [_footerView fileAttributes];
}

- (void)pause {
    [_footerView pause];
}

- (void)play {
    [_footerView play];
}

- (void)upload {
    [_footerView upload];
}

- (BOOL)removeFile:(NSURL *)fileURL {
    return [_footerView removeFile:fileURL];
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
