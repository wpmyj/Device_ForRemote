//
//  MHACPartnerControlHeaderView.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"
#import "MHGatewayFMControlView.h"
#import "MHLumiPageControl.h"

typedef enum : NSInteger{
    Acpartner_MainPage_AddAC = 0,
    Acpartner_MainPage_ACDetail,
    Acpartner_MainPage_FM,
}DetailType;

typedef void (^navigaitonCallBack)(DetailType type);


@interface MHACPartnerControlHeaderView : UIView
@property (nonatomic, strong) UIScrollView *mainPageScrollView;
@property (nonatomic, strong) UIView *headerBufferView;
@property (nonatomic, strong) MHLumiPageControl *mainPageControll;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, copy) navigaitonCallBack clickCallBack;

- (void)updateMainPageStatus;

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner* )acpartner;

@end
