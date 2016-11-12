//
//  MHGatewaySceneTitleView.h
//  MiHome
//
//  Created by ayanami on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHGatewaySceneTitleView : UIView



@property (nonatomic, copy) void (^chooseDeviceClick)(void);

- (void)updateDeviceName:(NSString *)name arrowImage:(NSString *)imageName;

@end
