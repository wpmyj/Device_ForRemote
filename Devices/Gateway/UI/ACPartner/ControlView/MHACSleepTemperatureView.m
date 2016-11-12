//
//  MHACSleepTemperatureView.m
//  MiHome
//
//  Created by ayanami on 16/7/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACSleepTemperatureView.h"
#import "MHLMVerticalSlider.h"


#define kLeadSpacing 25 * ScaleWidth
#define kSliderSpacing 40 * ScaleWidth
#define kTempSpacing 60 * ScaleWidth
#define kLabelSpacing 15 * ScaleWidth
#define kSliderHeight 240 * ScaleHeight

@interface MHACSleepTemperatureView ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *afterStart;
@property (nonatomic, strong) UILabel *beforeEnd;
@property (nonatomic, strong) UILabel *endLabel;

@property (nonatomic, strong) UILabel *startTime;
@property (nonatomic, strong) UILabel *afterStartTime;
@property (nonatomic, strong) UILabel *beforeEndTime;
@property (nonatomic, strong) UILabel *endTime;

@property (nonatomic, strong) MHLMVerticalSlider *startSlider;
@property (nonatomic, strong) MHLMVerticalSlider *afterStartSlider;
@property (nonatomic, strong) MHLMVerticalSlider *beforeEndSlider;
@property (nonatomic, strong) MHLMVerticalSlider *endSlider;

@property (nonatomic, strong) NSMutableArray *pointArray;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) CAShapeLayer *chartLayer;


@end

@implementation MHACSleepTemperatureView
- (id)initWithFrame:(CGRect)frame acpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super initWithFrame:frame];
    if (self) {
        self.acpartner = acpartner;
         self.pointArray =  [NSMutableArray new];

        [self buildSubviews];
    }
    return self;
}



- (void)buildSubviews {
    XM_WS(weakself);
    self.backgroundColor = [UIColor whiteColor];
    
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.chartLayer = [[CAShapeLayer alloc] init];
    
    //开始
    //温度
    self.startLabel = [[UILabel alloc] init];
    self.startLabel.textAlignment = NSTextAlignmentCenter;
    self.startLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.startLabel.font = [UIFont systemFontOfSize:14.0f];
    //    self.startLabel.text = @"26℃";
    [self addSubview:self.startLabel];

    
    //slider
    self.startSlider = [[MHLMVerticalSlider alloc] initWithFrame:CGRectMake(0, 0, kLeadSpacing, kSliderHeight) thumbImage:[UIImage imageNamed:@"acpartner_custom_sliderthumb"] popImage:[UIImage imageNamed:@"acpartner_custom_pop"] handle:^(CGFloat currentValue, CGPoint thumbCenter) {
//        NSLog(@"%@", weakself);
//        NSLog(@"当前值%lf", currentValue);
//        NSLog(@"起始时间的%lf, %lf", thumbFrame.origin.y, thumbFrame.origin.x);//
//        CGRect newRect = [thumb convertRect:thumbFrame toView:weakself];
//        NSLog(@"坐标转化后的起始时间%lf, %lf", newRect.origin.y, newRect.origin.x);
        CGPoint newPoint = CGPointMake(thumbCenter.x + kLeadSpacing, thumbCenter.y + kTempSpacing);
        if (weakself.pointArray.count >= 4) {
            [weakself.pointArray replaceObjectAtIndex:0 withObject:@[ @(newPoint.x), @(newPoint.y) ]];
            [weakself setNeedsDisplay];
        }
        else {
            [weakself.pointArray addObject:@[ @(newPoint.x), @(newPoint.y) ]];
        }
        if (weakself.beginTemp) {
            weakself.beginTemp((int)currentValue);
        }
        weakself.startLabel.text = [NSString stringWithFormat:@"%d℃", (int)currentValue];
//        weakself.startLabel.text = [NSString stringWithFormat:@"%.0f℃", currentValue];
    }];
    self.startSlider.minimumValue = TEMPERATUREMIN;
    self.startSlider.maximumValue = TEMPERATUREMAX;
    [self addSubview:self.startSlider];
    [self.startSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.mas_left).with.offset(kLeadSpacing);
        make.top.mas_equalTo(weakself.mas_top).with.offset(kTempSpacing);
        make.size.mas_equalTo(CGSizeMake(kLeadSpacing, kSliderHeight));
    }];
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.startSlider);
        make.top.mas_equalTo(weakself.mas_top).with.offset(kLabelSpacing);
    }];
    [self.startSlider setSliderValue:26 animated:NO];

    
   

    
    //时间
    self.startTime = [[UILabel alloc] init];
    self.startTime.textAlignment = NSTextAlignmentCenter;
    self.startTime.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.startTime.font = [UIFont systemFontOfSize:14.0f];
    self.startTime.text = @"22:00";
    [self addSubview:self.startTime];
    [self.startTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.startSlider.mas_bottom).with.offset(kLabelSpacing);
        make.centerX.equalTo(weakself.startSlider);
    }];
   

    //开始一个小时
    self.afterStart = [[UILabel alloc] init];
    self.afterStart.textAlignment = NSTextAlignmentCenter;
    self.afterStart.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.afterStart.font = [UIFont systemFontOfSize:14.0f];
    self.afterStart.backgroundColor = [UIColor clearColor];
    //    self.afterStart.text = @"28℃";
    [self addSubview:self.afterStart];
    
    self.afterStartSlider = [[MHLMVerticalSlider alloc] initWithFrame:CGRectMake(0, 0, kLeadSpacing, kSliderHeight) thumbImage:[UIImage imageNamed:@"acpartner_custom_sliderthumb"] popImage:[UIImage imageNamed:@"acpartner_custom_pop"] handle:^(CGFloat currentValue, CGPoint thumbCenter) {
//        NSLog(@"%@", weakself);
//        NSLog(@"当前值%lf", currentValue);
//        NSLog(@"起始时间的%lf, %lf", thumbCenter.y, thumbCenter.x);//
//        CGPoint newPoint = [thumb convertRect:thumbFrame toView:weakself];
//        NSLog(@"坐标转化后的起始时间%lf", weakself.afterStartSlider.frame.origin.x);
        CGPoint newPoint = CGPointMake(thumbCenter.x + kLeadSpacing * 2 + kSliderSpacing, thumbCenter.y + kTempSpacing);
        if (weakself.pointArray.count >= 4) {
            [weakself.pointArray replaceObjectAtIndex:1 withObject:@[ @(newPoint.x), @(newPoint.y) ]];
            [weakself setNeedsDisplay];
        }
        else {
            [weakself.pointArray addObject:@[ @(newPoint.x), @(newPoint.y) ]];
        }
        if (weakself.afterTemp) {
            weakself.afterTemp((int)currentValue);
        }
//        weakself.afterStart.text = [NSString stringWithFormat:@"%.0f℃", currentValue];
        weakself.afterStart.text = [NSString stringWithFormat:@"%d℃", (int)currentValue];

    }];
    self.afterStartSlider.minimumValue = TEMPERATUREMIN;
    self.afterStartSlider.maximumValue = TEMPERATUREMAX;
    [self addSubview:self.afterStartSlider];
    [self.afterStartSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.startSlider.mas_right).with.offset(kSliderSpacing);
        make.centerY.equalTo(weakself.startSlider);
        make.size.mas_equalTo(CGSizeMake(kLeadSpacing, kSliderHeight));
    }];
  
    [self.afterStart mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakself.mas_left).with.offset(kSliderSpacing * 2 + kLeadSpacing);
        make.centerX.equalTo(weakself.afterStartSlider);
        make.centerY.equalTo(weakself.startLabel);
    }];

    [self.afterStartSlider setSliderValue:28 animated:NO];

    
    self.afterStartTime = [[UILabel alloc] init];
    self.afterStartTime.textAlignment = NSTextAlignmentCenter;
    self.afterStartTime.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.afterStartTime.font = [UIFont systemFontOfSize:14.0f];
    self.afterStartTime.text = @"23:00";
    [self addSubview:self.afterStartTime];
    [self.afterStartTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.afterStartSlider.mas_bottom).with.offset(kLabelSpacing);
        make.centerX.equalTo(weakself.afterStartSlider);
    }];

    
    //结束
    
    self.endLabel = [[UILabel alloc] init];
    self.endLabel.textAlignment = NSTextAlignmentCenter;
    self.endLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.endLabel.font = [UIFont systemFontOfSize:14.0f];
    //    self.endLabel.text = @"26℃";
    [self addSubview:self.endLabel];

    self.endSlider = [[MHLMVerticalSlider alloc] initWithFrame:CGRectMake(40, 60, kLeadSpacing, kSliderHeight) thumbImage:[UIImage imageNamed:@"acpartner_custom_sliderthumb"] popImage:[UIImage imageNamed:@"acpartner_custom_pop"] handle:^(CGFloat currentValue, CGPoint thumbCenter) {
//        NSLog(@"%lf", thumbCenter.y);//
        CGPoint newPoint = CGPointMake(WIN_WIDTH - kLeadSpacing - kLeadSpacing / 2, thumbCenter.y + kTempSpacing);
        if (weakself.pointArray.count >= 4) {
            [weakself.pointArray replaceObjectAtIndex:3 withObject:@[ @(newPoint.x), @(newPoint.y) ]];
            [weakself setNeedsDisplay];
        }
        else {
            [weakself.pointArray addObject:@[ @(newPoint.x), @(newPoint.y) ]];
        }
        if (weakself.endTemp) {
            weakself.endTemp((int)currentValue);
        }
//        weakself.endLabel.text = [NSString stringWithFormat:@"%.0f℃", currentValue];
        weakself.endLabel.text = [NSString stringWithFormat:@"%d℃", (int)currentValue];

    }];
    self.endSlider.minimumValue = TEMPERATUREMIN;
    self.endSlider.maximumValue = TEMPERATUREMAX;
    [self addSubview:self.endSlider];
    [self.endSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.mas_right).with.offset(-kLeadSpacing);
        make.centerY.equalTo(weakself.startSlider);
        make.size.mas_equalTo(CGSizeMake(kLeadSpacing, kSliderHeight));
    }];

       [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(weakself.mas_right).with.offset(-kLeadSpacing);
        //        make.top.mas_equalTo(weakself.mas_top).with.offset(kLabelSpacing);
        make.centerY.equalTo(weakself.startLabel);
        make.centerX.equalTo(weakself.endSlider);
    }];
    [self.endSlider setSliderValue:26 animated:NO];


    
    self.endTime = [[UILabel alloc] init];
    self.endTime.textAlignment = NSTextAlignmentCenter;
    self.endTime.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.endTime.font = [UIFont systemFontOfSize:14.0f];
    self.endTime.text = @"7:00";
    [self addSubview:self.endTime];
    [self.endTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.endSlider.mas_bottom).with.offset(kLabelSpacing);
        make.centerX.equalTo(weakself.endSlider);
    }];

    
    //结束前一个小时
    self.beforeEnd = [[UILabel alloc] init];
    self.beforeEnd.textAlignment = NSTextAlignmentCenter;
    self.beforeEnd.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.beforeEnd.font = [UIFont systemFontOfSize:14.0f];
    //    self.beforeEnd.text = @"28℃";
    [self addSubview:self.beforeEnd];

    self.beforeEndSlider = [[MHLMVerticalSlider alloc] initWithFrame:CGRectMake(40, 60, kLeadSpacing,kSliderHeight) thumbImage:[UIImage imageNamed:@"acpartner_custom_sliderthumb"] popImage:[UIImage imageNamed:@"acpartner_custom_pop"] handle:^(CGFloat currentValue, CGPoint thumbCenter) {
        NSLog(@"%lf", thumbCenter.y);//
        CGPoint newPoint = CGPointMake(WIN_WIDTH - kLeadSpacing * 2.5 - kSliderSpacing, thumbCenter.y + kTempSpacing);
        if (weakself.pointArray.count >= 4) {
            [weakself.pointArray replaceObjectAtIndex:2 withObject:@[ @(newPoint.x), @(newPoint.y) ]];
        }
        else {
            [weakself.pointArray addObject:@[ @(newPoint.x), @(newPoint.y) ]];
            [weakself.pointArray exchangeObjectAtIndex:3 withObjectAtIndex:2];
        }
        [weakself setNeedsDisplay];
        if (weakself.endBeforeTemp) {
            weakself.endBeforeTemp((int)currentValue);
        }
        weakself.beforeEnd.text = [NSString stringWithFormat:@"%d℃", (int)currentValue];
//        weakself.beforeEnd.text = [NSString stringWithFormat:@"%.0f℃", currentValue];
        
    }];
    self.beforeEndSlider.minimumValue = TEMPERATUREMIN;
    self.beforeEndSlider.maximumValue = TEMPERATUREMAX;
    [self addSubview:self.beforeEndSlider];
    [self.beforeEndSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.endSlider.mas_left).with.offset(-kSliderSpacing);
        make.centerY.equalTo(weakself.startSlider);
        make.size.mas_equalTo(CGSizeMake(kLeadSpacing, kSliderHeight));
    }];

    
      [self.beforeEnd mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(weakself.mas_right).with.offset(-kSliderSpacing * 2 - kLeadSpacing);
        //        make.top.mas_equalTo(weakself.mas_top).with.offset(kLabelSpacing);
        make.centerY.equalTo(weakself.startLabel);
        make.centerX.equalTo(weakself.beforeEndSlider);
    }];
    
    [self.beforeEndSlider setSliderValue:28 animated:NO];



    self.beforeEndTime = [[UILabel alloc] init];
    self.beforeEndTime.textAlignment = NSTextAlignmentCenter;
    self.beforeEndTime.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.beforeEndTime.font = [UIFont systemFontOfSize:14.0f];
    self.beforeEndTime.text = @"6:00";
    [self addSubview:self.beforeEndTime];
    [self.beforeEndTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.beforeEndSlider.mas_bottom).with.offset(kLabelSpacing);
        make.centerX.equalTo(weakself.beforeEndSlider);
    }];

    
}


- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
//    NSLog(@"%@", self.pointArray);
    
    NSArray *firstArray = self.pointArray[0];
    
    [path moveToPoint:CGPointMake([firstArray[0] floatValue], [firstArray[1] floatValue])];
    
    for (int i = 1; i < self.pointArray.count; i ++) {
        NSArray *tempPoint = self.pointArray[i];
        [path addLineToPoint:CGPointMake([tempPoint[0] floatValue], [tempPoint[1] floatValue])];
    }
    
    //曲线,日后可能需要
//    path addCurveToPoint:<#(CGPoint)#> controlPoint1:<#(CGPoint)#> controlPoint2:<#(CGPoint)#>
    
    self.chartLayer.path = path.CGPath;
    self.chartLayer.strokeColor = [MHColorUtils colorWithRGB:0x888888].CGColor;
    self.chartLayer.fillColor = [UIColor clearColor].CGColor;
    self.chartLayer.lineWidth = 2;
    
    [self.chartLayer removeFromSuperlayer];
    [self.bgView.layer addSublayer:self.chartLayer];
}

- (void)reloadView:(NSArray *)tempArray timeArray:(NSArray *)timeArray {
    self.startTime.text = [NSString stringWithFormat:@"%02ld:%02ld", [timeArray[0] integerValue], [timeArray[2] integerValue]];
    NSInteger after = [timeArray[0] integerValue] + 1;
    if (after == 24) {
        after = 0;
    }
    self.afterStartTime.text = [NSString stringWithFormat:@"%02ld:%02ld", after, [timeArray[2] integerValue]];
    
    NSInteger endBefore = [timeArray[1] integerValue] - 1;
    if (endBefore < 0) {
        endBefore = 23;
    }
    self.beforeEndTime.text =[NSString stringWithFormat:@"%02ld:%02ld",  endBefore, [timeArray[3] integerValue]];
    self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld", [timeArray[1] integerValue], [timeArray[3] integerValue]];

    [self.startSlider setSliderValue:[tempArray[0] floatValue] animated:NO];
    [self.afterStartSlider setSliderValue:[tempArray[1] floatValue] animated:NO];
    [self.beforeEndSlider setSliderValue:[tempArray[2] floatValue] animated:NO];
    [self.endSlider setSliderValue:[tempArray[3] floatValue] animated:NO];
}

@end
