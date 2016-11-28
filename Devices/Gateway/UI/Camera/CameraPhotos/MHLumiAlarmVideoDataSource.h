//
//  MHLumiAlarmVideoDataSource.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHLumiPhotoGridDataSourceProtocol.h"
#import "MHLumiAlarmVideoRequest.h"

@class MHLumiAlarmVideoDataSource;
@protocol MHLumiAlarmVideoDataSourceDelegate <NSObject>

@optional
- (void)alarmVideoDataSourceDidUpdate:(MHLumiAlarmVideoDataSource *)AlarmVideoDataSource withError:(NSError *)error;

@end

@interface MHLumiAlarmVideoDataSource : NSObject<MHLumiPhotoGridDataSourceProtocol>
@property (nonatomic, weak) id<MHLumiAlarmVideoDataSourceDelegate> delegate;
@property (nonatomic, strong) MHLumiAlarmVideoRequest *request;
- (instancetype)initWithReques:(MHLumiAlarmVideoRequest *)request withDeviceDid:(NSString *)did;

//fetchData结束会走delegate的DidUpdate
- (void)fetchData;

@end
