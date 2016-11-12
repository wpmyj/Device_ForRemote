//
//  MHDataLaunch.h
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>

@interface MHDataLaunch : MHDataBase <NSCoding>

@property (nonatomic,strong) NSString *name;        //启动条件的名称
@property (nonatomic,strong) NSString *deviceName; //启动条件的device name
@property (nonatomic,strong) NSString *deviceDid; //启动条件的did
@property (nonatomic,strong) NSString *deviceKey; //启动事件 event
@property (nonatomic,strong) NSString *src; //启动条件的类别 “device” “timer”
@property (nonatomic,strong) id value;

@property (nonatomic,strong) NSString *model;
@property (nonatomic,strong) NSString *extra;
@property (nonatomic,strong) NSDictionary *timeSpan;
@property (nonatomic,strong) NSString *plug_id;

-(instancetype)initWithRecomObject:(id)object;
+(MHDataLaunch *)reBuildLaunchData:(NSMutableArray *)launchList withDeviceId:(NSString *)did;
+(NSDictionary *)launchToDictionary:(MHDataLaunch *)launch;

-(MHDataDeviceTimer *)timeSpanToTimer;
-(NSInteger)repeatDayFromWdayArray:(NSArray *)wday;
+(NSDictionary *)parseTimerToTimeSpanDictionary:(MHDataDeviceTimer *)timer;

@end
