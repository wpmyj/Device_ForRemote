//
//  MHGatewayScensView.h
//  MiHome
//
//  Created by Lynn on 9/4/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGatewayBase.h"
#import "MHIFTTTManager.h"

@interface MHGatewayScensView : UIView 

@property (nonatomic, strong) void(^onSelectedScene)(id scene);   //点击自动化
@property (nonatomic, strong) void(^onSelectedRecom)(id scene);   //点击推荐
@property (nonatomic, copy) void (^offlineRecord)(MHDataIFTTTRecord *record);

- (id)initWithFrame:(CGRect)frame andDevices:(MHDeviceGatewayBase *)device;

- (void)fetchRecordData ;

@end
