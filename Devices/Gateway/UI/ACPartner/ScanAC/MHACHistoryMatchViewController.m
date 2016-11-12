//
//  MHACHistoryMatchViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACHistoryMatchViewController.h"

@interface MHACHistoryMatchViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@end

@implementation MHACHistoryMatchViewController
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史匹配";
}


@end
