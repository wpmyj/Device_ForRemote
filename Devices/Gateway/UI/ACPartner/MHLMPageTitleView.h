//
//  MHLMPageTitleView.h
//  MiHome
//
//  Created by ayanami on 16/7/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSInteger{
    Scroll_Left = 0,
    Scroll_Right,
}TitleScrollDirection;
typedef void (^selectTitleCallback)(NSInteger selectIndex);

@interface MHLMPageTitleView : UIView


- (id)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray selectCallback:(selectTitleCallback)callback;

- (void)refreshCurrentOffsetX:(CGFloat)offsetX direction:(TitleScrollDirection)direction;

@end
