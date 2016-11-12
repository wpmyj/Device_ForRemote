//
//  MHACPartnerAddAcListViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

typedef enum : NSInteger {
    AUTO_MATCH,
    MANUAL_MACTCH,
    REMOTE_MACTCH,
} ACPARTNER_MATCH_MANNER;

@interface MHACPartnerAddAcListViewController : MHLuViewController


- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner mactchManner:(ACPARTNER_MATCH_MANNER)manner;

@end
