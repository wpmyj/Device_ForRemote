//
//  MHCCVideoViewController.m
//  MiHome
//
//  Created by ayanami on 8/20/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHCCVideoViewController.h"
#import "MHLumiSensorFooterView.h"
#import "MHCCVideoPlay.h"

@interface MHCCVideoViewController ()
@property (nonatomic, strong) MHDeviceCamera *camera;

@property (nonatomic, strong) MHLumiSensorFooterView *footerView;
@property (nonatomic, strong) MHCCVideoPlay *videoControl;


@end

@implementation MHCCVideoViewController


- (id)initWithCamera:(MHDeviceCamera *)camera {
    if(self = [super init]) {
        self.camera = camera;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = YES;
    self.view.backgroundColor = [MHColorUtils colorWithRGB:0x202f3b];
    
    
    XM_WS(weakself);
//    [self.camera getUidSuccess:^(id obj) {
//        NSLog(@"获取UID成功%@", obj);
//        weakself.camera.UID = [obj[@"result"] firstObject];
//        
//    } failure:^(NSError *error) {
//        NSLog(@"获取UID失败%@", error);
//    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)buildSubviews {
    [super buildSubviews];
    XM_WS(weakself);
    NSDictionary *footerSource = [self buildFooterResource];
    self.footerView = [[MHLumiSensorFooterView alloc] initWithSource:footerSource handle:^(NSInteger buttonIndex, NSInteger btnTag, NSString *name) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"零号机------");
                [weakself onPhotograph];
                break;
            case 1:
                NSLog(@"初号机------");
                [weakself onCall];
                break;
            case 2:
                NSLog(@"二号机------");
                [weakself videoCassette];
                break;
              default:
                break;
        }
    }];
    
    [self.footerView needFoldButton:NO];
    [self.view addSubview:self.footerView];
    
    self.videoControl = [[MHCCVideoPlay alloc] initWithSensor:self.camera];
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat footerHeight =  153 * ScaleHeight;

    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakself.view);
        make.height.mas_equalTo(footerHeight);
    }];
}

- (NSDictionary *)buildFooterResource {
    NSDictionary *source = nil;
    NSMutableArray *imageArray = [NSMutableArray arrayWithArray:@[ @"gateway_plug_kaion", @"acpartner_device_delay", @"acpartner_device_coolspeed"]];
    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[ @"拍照", @"通话", @"录像"]];
    /*
     NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式")
     */

       source = @{ kIMAGENAMEKEY : imageArray, kTEXTKEY : nameArray };
    return source;
}
#pragma makr - 控制
- (void)onPhotograph {
    [self startPlay];
}

- (void)onCall {
    
}

- (void)videoCassette {
    
}


#pragma mark - tutk
- (void)startPlay {
    XM_WS(weakself);
    
    [self.camera setVideoParams:@"on" Success:^(id obj) {
        [weakself.videoControl startFetchData];
    } failure:^(NSError *error) {
        NSLog(@"开机失败%@", error);
    }];
}


@end
