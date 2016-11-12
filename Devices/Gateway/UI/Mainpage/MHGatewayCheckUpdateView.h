//
//  MHGatewayCheckUpdateView.h
//  MiHome
//
//  Created by Lynn on 3/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"

@interface MHGatewayCheckUpdateView : UIView

@property (nonatomic,assign) BOOL isHide;
@property (nonatomic,weak) MHDeviceGateway *gateway;
@property (nonatomic, copy) void (^onUpdate)();

+ (MHGatewayCheckUpdateView *)shareInstance;

- (void)hide;

- (void)showUpdateViewInfoHeight:(CGFloat)infoViewHeight withInfo:(NSString *)info ;

@end
