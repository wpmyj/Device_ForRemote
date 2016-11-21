//
//  MHLumiAlarmVideoRequest.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHLumiAlarmVideoRequest : MHBaseRequest
@property (nonatomic, copy) NSString* did;
@property (nonatomic, assign) NSTimeInterval timeStart;
@property (nonatomic, assign) NSTimeInterval timeEnd;
@property (nonatomic, assign) NSInteger limit;
//@property (nonatomic, copy) NSString* group;
@end
