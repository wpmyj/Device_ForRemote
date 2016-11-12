//
//  MHLumiPopoverSlider.h
//  MiHome
//
//  Created by guhao on 2/26/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGatewayPopupView.h"
#import "AppDelegate.h"

@interface MHLumiPopoverSlider : UISlider

@property (strong, nonatomic) MHGatewayPopupView *popupView;
@property (nonatomic, strong) MHGatewayPopupView *windowPopupView;

@property (nonatomic, readonly) CGRect thumbRect;

@end
