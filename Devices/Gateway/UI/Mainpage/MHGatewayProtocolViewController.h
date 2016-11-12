//
//  MHGatewayProtocolViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLuViewController.h"
#import "GatewayProtocolGetter.h"

@interface MHGatewayProtocolViewController : MHLuViewController
@property (nonatomic, weak) id<GatewayProtocolGetter> dataGetter;

@end


