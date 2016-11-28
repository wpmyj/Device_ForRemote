//
//  MHLumiAlarmVideoResponse.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHLumiAlarmVideoDownloadUnit.h"

@interface MHLumiAlarmVideoResponse : MHBaseResponse
@property (nonatomic, strong) NSArray<MHLumiAlarmVideoDownloadUnit *> *alarmVideoDownloadUnits;
@end
