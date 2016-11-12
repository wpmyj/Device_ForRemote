//
//  MHGwMusicInvoker.h
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHGatewayUploadMusicManager.h"
#import "MHDeviceGateway.h"

#define DoorBell_RecordFile     @"doorbell"
#define Alarm_RecordFile        @"alarm"
#define AlarmClock_RecordFile   @"alarmclock"

@interface MHGwMusicInvoker : NSObject

@property (nonatomic,strong) void (^downloadSuccess)(NSDictionary *fileinfo);
@property (nonatomic,strong) void (^downloadProgress)(CGFloat progress);
@property (nonatomic,strong) void (^downloadStart)(CGFloat progress);

- (instancetype)initWithDevice:(MHDeviceGateway *)device;

//使用相对的路径，内部会转成正式全路径，file://....
- (void)userClickUpload:(NSURL *)filepath
     userDefineFileName:(NSString *)userfileName
           fileduration:(CGFloat)fileduration
              groupType:(NSString *)grouptype;

- (void)readPdataInvocationWithSuccess:(void (^)(BOOL))success
                            andFailure:(void (^)(NSError *))failure;

//配置网关下载音乐的列表
- (void)readGatwayDownloadListWithSuccess:(void (^)(id))success
                               andFailure:(void (^)(NSError *))failure;

- (void)setGatwayDownloadListWithValue:(NSArray *)value
                               Success:(void (^)(id))success
                            andFailure:(void (^)(NSError *))failure;

@end
