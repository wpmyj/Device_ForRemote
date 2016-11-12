//
//  MHACPartnerStatusView.h
//  MiHome
//
//  Created by ayanami on 16/5/31.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"


@interface MHACPartnerStatusView : UIView

-(id)initWithFrame:(CGRect)frame ACPartner:(MHDeviceAcpartner *)acpartner;

- (void)updateStatus;
@property (nonatomic, copy) void(^plusCallback)(void);
@property (nonatomic, copy) void(^lessCallback)(void);
@property (nonatomic, copy) void(^switchCallback)(void);

@end
