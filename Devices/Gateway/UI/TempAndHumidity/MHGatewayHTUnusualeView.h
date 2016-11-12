//
//  MHGatewayHTUnusualeView.h
//  MiHome
//
//  Created by ayanami on 16/6/3.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    Network_INDEX,//
    Environment_INDEX,//
} HT_TIPSTEXT_TYPE;

@interface MHGatewayHTUnusualeView : UIView

@property (nonatomic, copy) NSString *htDid;
@property (nonatomic, assign) HT_TIPSTEXT_TYPE type;

- (void)updateTipsText:(HT_TIPSTEXT_TYPE)type;
@end
