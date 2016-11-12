//
//  MHPlugView.h
//  MiHome
//
//  Created by Woody on 14/11/21.
//  Copyright (c) 2014年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiHomeKit/MHDataDeviceTimer.h>

typedef enum : NSInteger {
    MHPlugItemPlug,
    MHPlugItemUsb,
}   MHPlugItem;

@interface MHPlugView : UIView

@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, assign) NSInteger temperature; // 插座的温度

@property (nonatomic, copy) void (^countdown)(BOOL, MHPlugItem);

@property (nonatomic, strong) NSMutableArray* timerAllLineslist;

- (instancetype)initWithPlugItem:(MHPlugItem)item clickCallback:(void(^)(MHPlugView* ))callback;
- (void)timerCallback:(void(^)(MHPlugView* ))callback; // 打开定时页

- (void)updateTimerProgressView:(NSMutableArray*)timerAllLineslist countdownTimer:(MHDataDeviceTimer*)countdownTimer;
@end
