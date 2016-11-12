//
//  MHGatewayNightCircleColorView.h
//  MiHome
//
//  Created by guhao on 2/29/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGatewayNightLightDefine.h"


@interface MHGatewayNightCircleColorView : UIView

@property (nonatomic, assign) NSInteger oldRGB;
@property (nonatomic, assign) NSInteger oldLumin;
@property (nonatomic, assign) NSInteger newRGB;
@property (nonatomic, assign) NSInteger newLumin;
@end
