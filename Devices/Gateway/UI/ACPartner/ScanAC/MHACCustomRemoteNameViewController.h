//
//  MHACCustomRemoteNameViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/26.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACCustomRemoteNameViewController : MHLuViewController

@property (nonatomic, copy) NSString *cmd;

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner;

@end
