//
//  MHGatewayNatgasViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayNatgasViewController.h"
#import "MHGatewayNatgasSettingViewController.h"

@interface MHGatewayNatgasViewController ()
@property (nonatomic, strong) MHDeviceGatewaySensorNatgas *deviceNatgas;

@end

@implementation MHGatewayNatgasViewController
- (id)initWithDevice:(MHDevice *)device {
    if (self = [super initWithDevice:device]) {
        _deviceNatgas = (MHDeviceGatewaySensorNatgas* )device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.deviceNatgas readStatus];
    [self.deviceNatgas getPrivateProperty:HIGH_INDEX success:^(id obj) {
        
    } failure:^(NSError *v) {
        
    }];
    [self.deviceNatgas getPrivateProperty:SELFTEST_ENABLE_INDEX success:^(id obj) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)onMore:(id)sender {
    
    MHGatewayNatgasSettingViewController *natgasVC = [[MHGatewayNatgasSettingViewController alloc] initWithDeviceNatgas:self.deviceNatgas natgasController:self];
    [self.navigationController pushViewController:natgasVC animated:YES];

}
@end
