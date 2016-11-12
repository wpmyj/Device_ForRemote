//
//  MHLuViewController.h
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHViewController.h"
#import <MiHomeKit/MHStatReportManager.h>

@interface MHLuViewController : MHViewController

//对于复用页面，设置此ID，来区分统计
@property (nonatomic,strong) NSString *controllerIdentifier;

//统计点击事件
-(void)gw_clickMethodCountWithStatType:(NSString *)statType;

@end
