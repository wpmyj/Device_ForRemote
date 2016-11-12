//
//  MHGatewayControlHeaderView.h
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"
#import "MHGatewayFMControlView.h"
#import "MHLumiPageControl.h"

typedef void (^navigaitonCallBack)(void);

@interface MHGatewayControlHeaderView : UIView

@property (nonatomic, strong) UIScrollView *mainPageScrollView;
@property (nonatomic, strong) UIView *headerBufferView;
@property (nonatomic, strong) MHGatewayFMControlView *fmBgView;
@property (nonatomic, strong) MHLumiPageControl *mainPageControll;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, copy) navigaitonCallBack clickCallBack;
- (void)updateMainPageStatus;
- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway* )gateway;

@end
