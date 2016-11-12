//
//  MHLumiSensorFooterView.h
//  MiHome
//
//  Created by ayanami on 16/6/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
    UIPanGestureRecognizerDirectionUndefined,
    UIPanGestureRecognizerDirectionUp,
    UIPanGestureRecognizerDirectionDown,
    UIPanGestureRecognizerDirectionLeft,
    UIPanGestureRecognizerDirectionRight
};

typedef NS_ENUM(NSUInteger, LUMIFootviewType) {
    LUMI_Fixed_Order,//固定顺序(目前针对空调用)
    LUMI_Random_Order,//顺序不定
};

typedef void (^MHLumiSensorFooterHanlder)(NSInteger buttonIndex, NSInteger btnTag, NSString *name);

#define kIMAGENAMEKEY @"IMAGE"
#define kTEXTKEY      @"TEXT"

#define BtnTag_Add    10010
#define BtnTag_Light    95533
#define ItemDefaultHeigh     122 * ScaleHeight

@interface MHLumiSensorFooterView : UIView
@property (nonatomic, copy) void(^foldCallback)(void);
@property (nonatomic, copy) void(^panFoldCallback)(UIPanGestureRecognizerDirection);
@property (nonatomic, copy) void(^deleteCallback)(NSString *name);
/**
 *  按钮+文字(插座,单火,空调等底部的控制部分)
 *
 *  @param source imageName(array),  titleName(array), 初始化使用 kIMAGENAMEKEY,kTEXTKEY 作为key
 *  @param handle 按钮回调事件
 *
 *  @return return value description
 */
- (id)initWithSource:(NSDictionary *)source handle:(MHLumiSensorFooterHanlder)handle;

- (id)initWithFixedSource:(NSDictionary *)fixed customSource:(NSDictionary *)custom handle:(MHLumiSensorFooterHanlder)handle;

- (void)rebuildView:(NSDictionary *)newSource;
- (void)needFoldButton:(BOOL)need;
- (void)updateArrow:(NSString *)imageName;
- (void)hideDelete;

@end
