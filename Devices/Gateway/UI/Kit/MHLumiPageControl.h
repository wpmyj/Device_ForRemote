//
//  MHLumiPageControl.h
//  MiHome
//
//  Created by Lynn on 3/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger{
    Page_Left,
    Page_Right,
} PageDirection;

@interface MHLumiPageControl : UIView

@property (nonatomic,assign) NSInteger numberOfPages;
@property (nonatomic,assign) NSInteger currentPage;

- (void)animationActiveImage:(CGFloat)progress
                   direction:(PageDirection)direction;
@end
