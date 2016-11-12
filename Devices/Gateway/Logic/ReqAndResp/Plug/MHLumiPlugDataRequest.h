//
//  MHPlugDataRequest.h
//  MiHome
//
//  Created by Lynn on 11/12/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiPlugDataRequest : MHBaseRequest

@property (nonatomic,strong) NSString *deviceDid;
@property (nonatomic,strong) NSString *groupType;

//无dateString，则必须传 startDateString和endDateString
@property (nonatomic,strong) NSString *dateString;      //取当前时间，用这个字段取 统计某天某月电量时,startDate字串
@property (nonatomic,strong) NSString *startDateString; //取区间时间用下两个字断 startDate字串
@property (nonatomic,strong) NSString *endDateString;   //取区间时间用下两个字断 endDate字串

@end
