//
//  MHGatewayNightLightDefine.h
//  MiHome
//
//  Created by Lynn on 12/24/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//


#define kPadding 90 * ScaleHeight
#define kRadian  45 //角度
#define kSpacing 20 * ScaleHeight
#define PROGRESS_LINE_WIDTH 8 * ScaleWidth//弧线的宽度
#define kThumbRadius ScaleWidth * 70 //小圆半径
#define kThumbPadding ScaleWidth * 55 //拖动小圆的显示区域缩小5
#define kLogoColorViewSize 18 * ScaleWidth //显示当前颜色圆半径

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 ) //角度转化成PI
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

typedef void (^beginTouchCallback)(void);
typedef void (^endTouchCallback)(void);
typedef void (^cancleTouchCallback)(void);