//
//  MHLumiCameraVideoShareView.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHLumiCameraVideoShareView : UIView
@property (nonatomic, assign, readonly) BOOL isShowing;
- (void)showInDuration:(NSTimeInterval)duration;
- (void)hideInDuration:(NSTimeInterval)duration;
@end
