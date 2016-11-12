//
//  MHLumiCameraTimeLineCVCell.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiCameraTimeLineCVCell.h"
#import "MHLumiTimeGraduatorView.h"


@interface MHLumiCameraTimeLineCVCell()
@property (strong, nonatomic) UILabel *noteLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) MHLumiTimeGraduatorView *graduatorView;
@property (strong, nonatomic) MHLumiCameraTimeLineDataUnit *dataUnit;
@property (strong, nonatomic) NSSet<NSNumber *> *enableRange;
@property (strong, nonatomic) NSSet<NSNumber *> *disableRange;
@property (assign, nonatomic) CGFloat countOfSeparated;
@property (strong, nonatomic) NSMutableArray<UIView *> *statusViewArray;
- (UIView *)disableView;
@end

@implementation MHLumiCameraTimeLineCVCell
static CGFloat kNoteLabelHeightRatio = 4.0/17.0;
static CGFloat kGraduatorHeightRatio = 13.0/17.0;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupSubViews];
        [self configureLayout];
    }
    return self;
}

#pragma mark - private function
- (void)undateEnableRange{
    for (NSInteger index = 0; index < self.countOfSeparated; index ++) {
        [self.statusViewArray[index] removeFromSuperview];
    }
    [self setCellSeparatedStatus:MHLumiCameraTimeLineCVCellSeparatedStatusEnable withSet:self.enableRange];
    [self setCellSeparatedStatus:MHLumiCameraTimeLineCVCellSeparatedStatusDisable withSet:self.disableRange];
    [self updateStatusViewsFrame];
}

- (void)setCellSeparatedStatus:(MHLumiCameraTimeLineCVCellSeparatedStatus)status withSet:(NSSet<NSNumber *> *)set{
    if (set == nil){
        return;
    }
    switch (status) {
        case MHLumiCameraTimeLineCVCellSeparatedStatusEnable:
            for (NSNumber *number in set.allObjects) {
                NSInteger index = number.integerValue;
                if (index < self.statusViewArray.count){
                    [self.statusViewArray[index] removeFromSuperview];
                }
            }
            break;
        case MHLumiCameraTimeLineCVCellSeparatedStatusDisable:
            for (NSNumber *number in set.allObjects) {
                NSInteger index = number.integerValue;
                if (index < self.statusViewArray.count){
                    [self.statusViewArray[index] removeFromSuperview];
                    [self.statusViewArray removeObjectAtIndex:index];
                    [self.statusViewArray insertObject:[self disableView] atIndex:index];
                    [self.contentView addSubview:self.statusViewArray[index]];
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark
- (void)configureCellWithDataUnit:(MHLumiCameraTimeLineDataUnit *)dataUnit{
    self.dataUnit = dataUnit;
    self.timeLabel.text = dataUnit.timeRepresentString;
    self.noteLabel.text = dataUnit.dateRepresentString;
    self.noteLabel.hidden = !dataUnit.isNeedShowTimeNoteLabel;
    self.graduatorView.lineCount = dataUnit.countOfSeparated + 1;
    self.countOfSeparated = dataUnit.countOfSeparated;
    self.enableRange = dataUnit.enableRange;
    self.disableRange = dataUnit.disableRange;
    [self undateEnableRange];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat contentViewHeight = CGRectGetHeight(self.contentView.frame);
    self.noteLabel.frame = CGRectMake(0, 0, contentViewWidth, contentViewHeight * kNoteLabelHeightRatio);
    self.graduatorView.frame = CGRectMake(0, CGRectGetHeight(self.noteLabel.frame), contentViewWidth, contentViewHeight * kGraduatorHeightRatio);
    self.timeLabel.frame = CGRectMake(0, 0, contentViewWidth-4, CGRectGetHeight(self.graduatorView.frame)/2.0);
    self.timeLabel.center = CGPointMake(contentViewWidth/2.0, CGRectGetHeight(self.graduatorView.frame)/2.0);
    [self updateStatusViewsFrame];
}

- (void)updateStatusViewsFrame{
    if (self.countOfSeparated <= 0){
        return;
    }
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat contentViewHeight = CGRectGetHeight(self.contentView.frame);
    CGFloat w = contentViewWidth/self.countOfSeparated;
    for (NSInteger index = 0; index < self.countOfSeparated; index ++) {
        self.statusViewArray[index].frame = CGRectMake(index*w, 0, w, contentViewHeight);
    }
}

#pragma mark - setupSubViews
- (void)setupSubViews{
    [self.contentView addSubview:self.noteLabel];
    [self.contentView addSubview:self.graduatorView];
    [self.graduatorView addSubview:self.timeLabel];
}

- (void)configureLayout{
    
}

#pragma mark - getter and setter
- (UILabel *)noteLabel{
    if (!_noteLabel){
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        _noteLabel = label;
    }
    return _noteLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel){
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        _timeLabel = label;
    }
    return _timeLabel;
}

- (MHLumiTimeGraduatorView *)graduatorView{
    if (!_graduatorView){
        MHLumiTimeGraduatorView *aView = [[MHLumiTimeGraduatorView alloc] init];
        aView.lineCount = 7;
        aView.backgroundColor = [UIColor clearColor];
        _graduatorView = aView;
    }
    return _graduatorView;
}

- (UIView *)disableView{
    UIView *aView = [[UIView alloc] init];
    aView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
    return aView;
}

- (NSMutableArray<UIView *> *)statusViewArray{
    if (!_statusViewArray){
        _statusViewArray = [NSMutableArray arrayWithCapacity:self.countOfSeparated];
        for (NSInteger index = 0; index < self.countOfSeparated; index ++) {
            UIView *todoView = [[UIView alloc] init];
            [_statusViewArray addObject:todoView];
        }
    }
    return _statusViewArray;
}

@end
