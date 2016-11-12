//
//  MHDataAction.h
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>

@interface MHDataAction : MHDataBase <NSCoding>

@property (nonatomic,strong) NSString *name;  //keyname,执行任务名称
@property (nonatomic,strong) NSString *deviceModel; //执行model
@property (nonatomic,strong) NSString *deviceName; //执行任务device name
@property (nonatomic,strong) NSString *type;

//下面的字段都是action的payload
@property (nonatomic,strong) NSString *command; //执行任务的命令
@property (nonatomic,strong) NSString *deviceDid; //执行任务的设备did
@property (nonatomic,strong) NSString *total_length;
@property (nonatomic,strong) NSString *value;
@property (nonatomic,strong) NSString *extra;
@property (nonatomic,strong) NSString *plug_id;

-(instancetype)initWithRecomObject:(id)object;
+(NSDictionary *)actionToDictionary:(MHDataAction *)action;
+(MHDataAction *)reBuildActionData:(NSMutableArray *)actionList withDeviceId:(NSString *)did;

@end
