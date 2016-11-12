//
//  MHLumiFMVolumeControl.h
//  MiHome
//
//  Created by Lynn on 12/24/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLumiFmPlayerDefine.h"
#import "MHDeviceGateway.h"

typedef enum : NSInteger {
    NumberType_Brightness = 1,
}   NumberType;
@interface MHLumiFMVolumeControl : UIView

@property (nonatomic,assign) BOOL isHide;
@property (nonatomic,weak) MHDeviceGateway *gateway;

+ (MHLumiFMVolumeControl *)shareInstance;

- (void)hide;

#pragma mark - volume control
@property (nonatomic,strong) void (^volumeControlCallBack)(NSInteger value);

- (void)showVolumeControl:(CGFloat)yPosition withVolumeValue:(NSInteger)volumeValue ;

- (void)showNumberControl:(CGFloat)yPosition withNewValue:(NSInteger)newValue WithNumberType:(NSInteger)numberType;


#pragma mark - list control
@property (nonatomic,strong) void (^timerControlCallBack)(NSString *value);

- (void)showTimerControler:(CGFloat)yPosition withTimerList:(NSArray *)timerList ;


@end
