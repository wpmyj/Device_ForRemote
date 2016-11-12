//
//  MHLumiSensorSelfCheckEnableRequest.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHLumiSensorSelfCheckEnableRequest : MHBaseRequest
@property (nonatomic, copy) NSString* did;
@property (nonatomic, assign) bool enable;
@end
