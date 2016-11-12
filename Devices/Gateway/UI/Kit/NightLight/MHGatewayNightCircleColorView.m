//
//  MHGatewayNightCircleColorView.m
//  MiHome
//
//  Created by guhao on 2/29/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNightCircleColorView.h"


@interface MHGatewayNightCircleColorView ()
{
    CGFloat beginR;
    CGFloat beginG;
    CGFloat beginB;
    CGFloat endR;
    CGFloat endG;
    CGFloat endB;
}
@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, strong) UIColor *trackTintColor;
@property (nonatomic, assign) CGFloat backgroundRingWidth;
@property (nonatomic, assign) CGFloat progressRingWidth;

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

@property (nonatomic, strong) NSArray *colorsArray;


@end

@implementation MHGatewayNightCircleColorView
-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.opaque = NO;
        //Define the circle radius taking into account the safe area
        _radius = self.frame.size.width - PROGRESS_LINE_WIDTH;
//        [self setupLumin:16711764];
        [self setupLumin:0xFFFFFFFF];
        self.backgroundColor = [UIColor clearColor];
        _colorsArray = @[[MHColorUtils colorWithRGB:0xFFFFFFFF],//白色
                         [MHColorUtils colorWithRGB:0xFFFFFF00],//黄色
                         [MHColorUtils colorWithRGB:0xFFFF0000],//红色
                         [MHColorUtils colorWithRGB:0xFFFF00FF],//粉色
                         [MHColorUtils colorWithRGB:0xFF0000FF],//蓝色
                         [MHColorUtils colorWithRGB:0xFF00FFFF],//天蓝
                         [MHColorUtils colorWithRGB:0xFF00FF00]];//绿色
    }
    
    return self;
}
#pragma mark - Drawing Functions -
//Use the draw rect to draw the Background, the Circle and the Handle
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
//    [self drawBackground];
    [self drawProgress];
}

- (void)drawBackground
{
//    _backgroundRingWidth = 10.0f;
    //    _progressRingWidth = 10.0f;
    //
    //    _backgroundLayer = [CAShapeLayer layer];
    //    _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
    //    _backgroundLayer.strokeColor = _trackTintColor.CGColor;
    //    _backgroundLayer.lineCap = kCALineCapRound;
    //    _backgroundLayer.lineWidth = _backgroundRingWidth;
    //    [self.layer addSublayer:_backgroundLayer];
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = startAngle + (2.0 * M_PI);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _backgroundRingWidth) / 2.0;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = _progressRingWidth;
    path.lineCapStyle = kCGLineCapRound;
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    _backgroundLayer.path = path.CGPath;
    
}

- (void)drawProgress
{
    //7种颜色,分六段绘制
    int parts = 6;
    

    //圆弧起始弧度
    CGFloat startAngle = M_PI_4 + M_PI_2;
    //视图中心
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    //半径大小
    CGFloat radius = (self.bounds.size.width - PROGRESS_LINE_WIDTH) / 2.0;
    //圆弧结束弧度
    CGFloat endAngle = 0.0;
    int sectors = 90;
    float angle  = M_PI_4 / sectors;

    for (int j = 0; j < parts; j++) {
        startAngle = M_PI_2 + (j  + 1)* M_PI_4;
        if (startAngle == M_PI * 2.0) {
            startAngle = M_PI * 0;
        }
        endAngle = startAngle + M_PI_4;
        //获取起始颜色的RGB值
        [_colorsArray[j] getRed:&beginR green:&beginG blue:&beginB alpha:nil];
        //获取结束颜色的RGB值
        [_colorsArray[j + 1] getRed:&endR green:&endG blue:&endB alpha:nil];
//        NSLog(@"起始红%lf, 起始绿%lf, 起始蓝%lf, 结束红%lf, 结束绿%lf, 结束蓝%lf", beginR, beginG, beginB, endR, endG, endB);
        CGFloat startAngleNeedDraw  = startAngle;
        /**
         *  每段分90份绘制,每段45°--等分255,微分思想实现渐变,便于通过颜色值计算出位置
         */
        UIBezierPath *sectorPath;
        for (int i = 0; i < sectors; i ++) {
            CGFloat ratio = (float)i / (float)sectors ;
            CGFloat R = beginR + (endR - beginR) * ratio ;
            CGFloat G = beginG + (endG - beginG) * ratio ;
            CGFloat B = beginB + (endB - beginB) * ratio ;
            //贝塞尔曲线 绘制圆弧 clockwise: 顺时针或者逆时针  YES : 顺时针  NO 表示逆时针绘制
            sectorPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngleNeedDraw + i * angle endAngle:startAngleNeedDraw + (i + 1) * angle + 0.001 clockwise:YES];
            if (i == 0) {
                sectorPath.lineCapStyle = kCGLineCapRound;
            }
            UIColor *color = [UIColor colorWithRed:R green:G blue:B alpha:1];
            //线宽
            [sectorPath setLineWidth:PROGRESS_LINE_WIDTH];
            //线头尾的样式设为圆角
            [sectorPath setLineCapStyle:kCGLineCapRound];
            //填充颜色
            [color setStroke];
            
            [sectorPath stroke];
        }
        
    }
}



- (void)setupLumin:(NSInteger)color
{
    int r = color >> 16 & 0xff;
    int g = color >> 8 & 0xff;
    int b = color & 0xff;
    long a = color >> 24;
    NSLog(@"红%d, 绿%d, 蓝%d, 透明度%ld", r, g, b, a);
    UIColor *c = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a/100.0f];
    CGFloat hue, sat, brightness, alpha;
    [c getHue:&hue saturation:&sat brightness:&brightness alpha:&alpha];
    NSLog(@"取值后的透明度%ld",(NSInteger)alpha);
    _oldRGB = color - (a << 24);
    _newRGB = _oldRGB;
    _oldLumin = alpha * 100;
    _newLumin = _oldLumin;
    NSLog(@"最终给slider的透明度%ld",_oldLumin);
    
}


@end
