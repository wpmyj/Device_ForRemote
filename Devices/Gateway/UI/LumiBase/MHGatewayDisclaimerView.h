//
//  MHGatewayDisclaimerView.h
//  MiHome
//
//  Created by Woody on 15/5/25.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHPopupViewBase.h"

@interface MHGatewayDisclaimerView : MHPopupViewBase

@property (nonatomic,strong) NSString *title;
@property (nonatomic, copy) void(^onOpenDisclaimerPage)(void);
@end
