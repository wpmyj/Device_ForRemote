//
//  MHACPartnerReMatchViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

typedef enum : NSInteger {
    REMACTCH_INDEX,//重新匹配
    MATCH_FAILURE_INDEX,//匹配失败
} ACPARTNER_REMATCH_TYPE;

@interface MHACPartnerReMatchViewController : MHLuViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner type:(ACPARTNER_REMATCH_TYPE)type;

@end
