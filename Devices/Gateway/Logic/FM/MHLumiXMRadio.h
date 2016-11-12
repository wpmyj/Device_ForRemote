//
//  MHLumiXMRadio.h
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiXMRadio : MHDataBase <NSCoding>

@property (nonatomic,strong) NSString *radioName;
@property (nonatomic,strong) NSString *radioId;
@property (nonatomic,strong) NSString *radioCoverSmallUrl;
@property (nonatomic,strong) NSString *radioCoverLargeUrl;
@property (nonatomic,strong) NSString *radioPlayCount;
@property (nonatomic,strong) NSString *radioDesc;
@property (nonatomic,strong) NSString *radioRateUrl;
@property (nonatomic,strong) NSString *radioLowRateUrl;
@property (nonatomic,strong) NSString *currentProgram;
@property (nonatomic,strong) NSString *radioCollection; // @"yes" @"no"
@property (nonatomic,strong) NSString *updateaTimeStamp; // unix time

+ (MHLumiXMRadio *)jsonToObject:(NSDictionary *)object ;

- (id)toJson ;

@end
