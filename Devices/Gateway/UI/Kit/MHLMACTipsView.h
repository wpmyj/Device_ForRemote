//
//  MHLMACTipsView.h
//  MiHome
//
//  Created by ayanami on 16/8/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHTipsView.h"

typedef void (^modelCallBack)(void);


@interface MHLMACTipsView : MHTipsView
+ (MHLMACTipsView*)shareInstance;

- (void)showTips:(NSString *)info modal:(BOOL)isModal handle:(modelCallBack)handle;



@end
