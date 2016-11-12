//
//  MHLumiFmPlayer.h
//  MiHome
//
//  Created by Lynn on 11/25/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLumiXMRadio.h"
#import "MHDeviceGateway.h"
#import "MHLumiFmPlayerDefine.h"

@interface MHLumiFmPlayer : UIView

+ (MHLumiFmPlayer *)shareInstance;

@property (nonatomic,strong) MHDeviceGateway *radioDevice;
@property (nonatomic,strong) MHLumiXMRadio *currentRadio;
@property (nonatomic,strong) NSString *currentProgramName;
@property (nonatomic,assign) BOOL isHide;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,strong) NSMutableArray *radioPlayList;

@property (nonatomic,copy) void (^showFullPlayerCallBack)();

@property (nonatomic,copy) void (^playCallBack)(MHLumiXMRadio *radio);
@property (nonatomic,copy) void (^pauseCallBack)(MHLumiXMRadio *radio);
@property (nonatomic, copy) void (^controlCallBack)(BOOL isPlaying);//获取FM状态,防止首页控制失败显示不一致

- (void)showMiniPlayer:(CGFloat)yPosition isMainPage:(BOOL)isMainPage;
- (void)setDeviceFMVolume:(NSInteger)value
              withSuccess:(void (^)(id obj))success
                  failure:(void (^)(NSError *error))failure;
- (void)showPlayerSubs;
- (void)hide;

- (void)pause ; 
- (void)play ;
- (void)playLast ;
- (void)playNext ;

@end
