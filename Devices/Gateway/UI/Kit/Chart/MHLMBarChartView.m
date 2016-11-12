//
//  MHLMBarChartView.m
//  MiHome
//
//  Created by Lynn on 12/14/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLMBarChartView.h"
#import "MHLumiDateTools.h"

@interface MHLMBarChartView ()

@property (nonatomic,assign) CGFloat vTotalSpace;
//Bar count , 一屏的Bar数量
@property (nonatomic,assign) NSInteger barCount;
@property (nonatomic,strong) NSString *currentHightlightIndex;

@end

@implementation MHLMBarChartView

- (id)initWithFrame:(CGRect)frame chartDataArray:(NSArray *)chartDataArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _dataSource = [chartDataArray mutableCopy];
        _barCount = _dataSource.count;
        _vTotalSpace = CGRectGetHeight(frame);
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _vTotalSpace = CGRectGetHeight(frame);
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    if(_dataSource != dataSource){
        _dataSource = dataSource;
        _barCount = dataSource.count;
        if(_dataSource && _dataSource.count){
            [self setNeedsDisplay];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat barSize = Screen_Width / _barCount;
    
    XM_WS(weakself);
    [_dataSource enumerateObjectsWithOptions:NSEnumerationReverse
                                  usingBlock:^(NSNumber *numberObj, NSUInteger idx, BOOL *stop) {
        
                                      CGFloat barHeight = numberObj.doubleValue * weakself.barHeightScale;
                                      CGFloat xBarPoint = Screen_Width - (weakself.barCount - idx) * barSize;
                                      CGFloat yBarPoint = weakself.vTotalSpace - barHeight;
                                      
                                      NSLog(@"totalSpace = %f",weakself.vTotalSpace);
                                      NSLog(@"barHeight = %f",barHeight);
                                      
                                      CAShapeLayer *bar = [[CAShapeLayer alloc] init];
                                      bar.frame = CGRectMake(xBarPoint + 1.5,
                                                             yBarPoint,
                                                             barSize - 3,
                                                             barHeight);

                                      bar.path = [UIBezierPath bezierPathWithRect:CGRectMake(0,
                                                                                             0 ,
                                                                                             barSize - 3,
                                                                                             barHeight)].CGPath;
                                      bar.fillColor = weakself.barOriginColor.CGColor;
                                      [weakself.layer addSublayer:bar];
                                      
                                      NSString *dateString = [weakself dateFormatter:weakself.dateLineSource[idx]];
                                      
                                      CGRect labelFrame = CGRectMake(xBarPoint, yBarPoint + barHeight + 5, barSize - 3, 20);
                                      UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
                                      label.text = dateString;
                                      label.font = [UIFont systemFontOfSize:9.5f];
                                      label.textAlignment = NSTextAlignmentCenter;
                                      label.textColor = [MHColorUtils colorWithRGB:0x7c7c7c];
                                      [weakself addSubview:label];
                                  }];
    
    [super drawRect:rect];
}

- (NSString *)dateFormatter:(NSString *)rawDateString {
    NSString *newDateString = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSDate *dateDate = [dateFormatter dateFromString:rawDateString];
    
    if ([_dateType isEqualToString:@"day"]){
        BOOL isThisYear = [MHLumiDateTools isThisYear:dateDate];
        BOOL isSeperateDay = [MHLumiDateTools isSeperateDayOfTheYear:dateDate];
        
        NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
        
        if (isSeperateDay && !isThisYear){
            newDateFormatter.dateFormat = @"yyyy-MM";
        }
        else {
            newDateFormatter.dateFormat = @"MM/dd";
        }
        newDateFormatter.timeZone = [NSTimeZone systemTimeZone];
        
        newDateString = [newDateFormatter stringFromDate:dateDate];
    }
    else if ([_dateType isEqualToString:@"month"]) {
        
        BOOL isThisYear = [MHLumiDateTools isThisYear:dateDate];
        BOOL isThisSeperateMonth = [MHLumiDateTools isSeperateMonthOfTheYear:dateDate];
        
        NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
        
        if (!isThisYear && isThisSeperateMonth) {
            newDateFormatter.dateFormat = @"yyyy-MM";
        }
        else {
            newDateFormatter.dateFormat = [NSString stringWithFormat:@"MM%@",
                                           NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quantvc.month", @"plugin_gateway", nil)];
        }
        newDateFormatter.timeZone = [NSTimeZone systemTimeZone];
        
        newDateString = [newDateFormatter stringFromDate:dateDate];
    }
    NSLog(@"%@", newDateString);
    
    return newDateString;
}

//让某个Bar变色
- (void)addBarAnimation:(NSInteger)barIdx {
    [self removeBarAnimation];
    
    self.currentHightlightIndex = [NSString stringWithFormat:@"%ld", barIdx];
    
    CAShapeLayer *bar = (CAShapeLayer *)self.layer.sublayers[barIdx * 2];
    bar.fillColor = _barHighlightColor.CGColor;
    
    UILabel *label = (UILabel *)[self.layer.sublayers[barIdx * 2 + 1] delegate];
    [label setTextColor:[MHColorUtils colorWithRGB:0x00a161]];
    [label setFont:[UIFont systemFontOfSize:11.f]];

    CGPoint orgCenter = label.center;
    [label sizeToFit];
    label.center = orgCenter;
    
//    CGFloat xBarPoint = label.frame.origin.x;
//    CGFloat yBarPoint = label.frame.origin.y;
//    CGFloat barSize = label.frame.size.width;
//    CGRect labelFrame = CGRectMake(xBarPoint - 3, yBarPoint, barSize + 6, 20);
//    label.frame = labelFrame;
}

- (void)removeBarAnimation {
    CAShapeLayer *bar = (CAShapeLayer *)self.layer.sublayers[_currentHightlightIndex.integerValue * 2];
    bar.fillColor = _barOriginColor.CGColor;
    
    UILabel *label = (UILabel *)[self.layer.sublayers[_currentHightlightIndex.integerValue * 2 + 1] delegate];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setFont:[UIFont systemFontOfSize:9.5f]];
    
    CGPoint orgCenter = label.center;
    [label sizeToFit];
    label.center = orgCenter;

//    CGFloat xBarPoint = label.frame.origin.x;
//    CGFloat yBarPoint = label.frame.origin.y;
//    CGFloat barSize = label.frame.size.width;
//    CGRect labelFrame = CGRectMake(xBarPoint + 3, yBarPoint, barSize - 6, 20);
//    label.frame = labelFrame;
}

@end