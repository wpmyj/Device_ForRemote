//
//  MHACPartnerTypeSearchViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"

@interface MHACPartnerTypeSearchViewController : MHLuViewController
- (id)initWithACList:(NSArray *)ACList;
@property (nonatomic, copy) void (^selectBrand)(NSInteger brand);

@end
