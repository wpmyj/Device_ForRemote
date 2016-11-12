//
//  MHGatewayPlugQuantViewController.h
//  MiHome
//
//  Created by Lynn on 9/21/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGatewaySensorPlug.h"

#define  kMonthDateType  10001
@interface MHGatewayPlugQuantViewController : MHLuViewController

@property (nonatomic,assign) NSInteger selectedType;

//- (id)initWithDevice:(MHDeviceGatewaySensorPlug *)devicePlug ;
- (id)initWithDevice:(MHDeviceGatewayBase *)devicePlug ;

@end
