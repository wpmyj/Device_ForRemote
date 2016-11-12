//
//  MHDataGatewayLog.h
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHDataGatewayLog : MHDataBase <NSCoding>

@property (nonatomic, strong) NSString *deviceClass;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString* did;
@property (nonatomic, copy) NSString* key;
@property (nonatomic, retain) NSDate* time;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString *subDeviceDid;
@property (nonatomic, copy) NSString* value;

@property (nonatomic, assign) BOOL hasPrev;
@property (nonatomic, assign) BOOL hasNext;
@property (nonatomic, assign) BOOL isFirst;

@end
