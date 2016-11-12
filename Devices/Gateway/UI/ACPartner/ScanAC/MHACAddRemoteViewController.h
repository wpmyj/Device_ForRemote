//
//  MHACAddRemoteViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACAddRemoteViewController : MHLuViewController
@property (nonatomic, copy) NSString *selectName;

@property (nonatomic, copy) void(^addCustomFucntion)(NSDictionary *footerSource);

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner;

@end
