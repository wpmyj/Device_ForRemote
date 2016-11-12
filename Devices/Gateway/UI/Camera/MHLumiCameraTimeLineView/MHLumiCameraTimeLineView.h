//
//  MHLumiCameraTimeLineView.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MHLumiCameraTimeLineView;
@protocol MHLumiCameraTimeLineViewDelegate <NSObject>
@optional
- (void)cameraTimeLineViewWillBeginDragging:(MHLumiCameraTimeLineView *)cameraTimeLineView;
- (void)cameraTimeLineViewEndDragging:(MHLumiCameraTimeLineView *)cameraTimeLineView;
- (void)cameraTimeLineViewDidScroll:(MHLumiCameraTimeLineView *)cameraTimeLineView;
@end


@interface MHLumiCameraTimeLineView : UIView
@property (nonatomic, strong, readonly) NSDate *currentDate;
@property (nonatomic, strong, readonly) NSDate *timeLineStartDate;
@property (nonatomic, strong, readonly) NSDate *timeLineEndDate;
@property (nonatomic, strong, readonly) UILabel *liveTimerLabel;
@property (nonatomic, strong, readonly) NSDate *markDateA;
@property (nonatomic, strong, readonly) NSDate *markDateB;
@property (nonatomic, assign, readonly, getter=isDraging) BOOL draging;
@property (weak, nonatomic) id<MHLumiCameraTimeLineViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame startDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

- (instancetype)initWithFrame:(CGRect)frame
                    startDate:(NSDate *)startDate
                   andEndDate:(NSDate *)endDate
               andDefaultDate:(NSDate *)defaultDate;

- (instancetype)initWithFrame:(CGRect)frame
                    startDate:(NSDate *)startDate
                   andEndDate:(NSDate *)endDate
               andDefaultDate:(NSDate *)defaultDate
                 andMarkDateA:(NSDate *)markDateA
                 andMarkDateB:(NSDate *)markDateB;
- (void)scrollToDate:(NSDate *)date andAnimated:(BOOL)animated;
- (void)markDateBAddTimeInterval:(NSTimeInterval)seconds andAnimated:(BOOL)animated;
@end
