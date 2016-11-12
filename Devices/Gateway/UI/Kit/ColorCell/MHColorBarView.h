//
//  MHColorBarView.h
//  MiHome
//
//  Created by Lynn on 7/28/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  @author Zechen Liu, 15-07-28 14:07:10
 *
 *  @brief  颜色条的View
 */
@interface MHColorBarView : UIView

@end


@class MHGatewayPickColorView;
typedef void(^MHGatewayColorPickerCallbackBlock)(CGFloat value);

@interface MHGatewayPickColorView : UIControl

@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign) CGFloat barStartXPoint;
@property (nonatomic, copy) MHGatewayColorPickerCallbackBlock callbackBlock;

@end
