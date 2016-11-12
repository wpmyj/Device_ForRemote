//
//  MHACPartnerDetailViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

#define kAC_SCENE_URL @"https://app-ui.aqara.cn/airPartnerGuide/index.html"


@interface MHACPartnerDetailViewController : MHLuViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner;

- (void)rebuildRemote:(NSDictionary *)source;

@end
