//
//  MHLumiCameraTimeLineView.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiCameraTimeLineView.h"
#import "MHLumiUIOneLineCollectionViewLayout.h"
#import "MHLumiCameraTimeLineCVCell.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"
#import "NSDate+lumiDateHelper.h"

@interface MHLumiCameraTimeLineView()<UICollectionViewDataSource,MHLumiUIOneLineCollectionViewLayoutDelegate,UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collentionView;
@property (strong, nonatomic) UIView *indicatorView;
@property (strong, nonatomic) UILabel *liveTimerLabel;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray <MHLumiCameraTimeLineDataUnit *>* timeLineDatasource;
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSDate *timeLineStartDate;
@property (strong, nonatomic) NSDate *timeLineEndDate;
@property (strong, nonatomic) NSDate *defaultDate;
@property (strong, nonatomic) NSDate *markDateA;
@property (strong, nonatomic) NSDate *markDateB;
@end

//
@implementation MHLumiCameraTimeLineView
static CGFloat kItemWidth = 80;
- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame startDate:nil andEndDate:nil andDefaultDate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame startDate:(NSDate *)startDate andEndDate:(NSDate *)endDate{
    return [self initWithFrame:frame startDate:startDate andEndDate:endDate andDefaultDate:startDate];
}

- (instancetype)initWithFrame:(CGRect)frame
                    startDate:(NSDate *)startDate
                   andEndDate:(NSDate *)endDate
               andDefaultDate:(NSDate *)defaultDate{
    return [self initWithFrame:frame startDate:startDate andEndDate:endDate andDefaultDate:defaultDate andMarkDateA:nil andMarkDateB:nil];
}

- (instancetype)initWithFrame:(CGRect)frame startDate:(NSDate *)startDate andEndDate:(NSDate *)endDate andDefaultDate:(NSDate *)defaultDate andMarkDateA:(NSDate *)markDateA andMarkDateB:(NSDate *)markDateB{
    self = [super initWithFrame:frame];
    if (self){
        _timeLineStartDate = startDate;
        _timeLineEndDate = endDate;
        _defaultDate = defaultDate;
        _currentDate = startDate;
        _markDateA = markDateA ? markDateA : startDate;
        _markDateB = markDateB ? markDateB : endDate;
        [self addSubview:self.collentionView];
        [self addSubview:self.indicatorView];
        [self addSubview:self.liveTimerLabel];
        self.timeLineDatasource = [self fetchTimeLineDataSource];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat w = CGRectGetWidth(self.bounds);
    self.collentionView.frame = self.bounds;
    self.collentionView.contentInset = UIEdgeInsetsMake(0, w/2.0, 0, w/2.0);
    CGFloat indicatorViewWidth = 2;
//    4.0/17.0;
//    13.0/17.0;
    self.indicatorView.frame = CGRectMake((CGRectGetWidth(self.bounds)-indicatorViewWidth)/2.0,
                                          h*4.0/17.0,
                                          indicatorViewWidth,
                                          h*13.0/17.0);
    self.liveTimerLabel.frame = CGRectMake((CGRectGetWidth(self.bounds)-kItemWidth*2)/2.0,
                                           0,
                                           kItemWidth*2,
                                           h*4.0/17.0);
    if (self.collentionView.contentSize.width > 0){
        if (self.defaultDate){
            [self scrollToDate:self.defaultDate andAnimated:NO];
            self.defaultDate = nil;
        }else{
            [self scrollToDate:self.currentDate andAnimated:NO];
        }
    }
}

- (void)markDateBAddTimeInterval:(NSTimeInterval)seconds andAnimated:(BOOL)animated{
    NSTimeInterval diff = self.timeLineEndDate.timeIntervalSince1970 - self.markDateB.timeIntervalSince1970;
    NSDate *todoDate = [self.markDateB dateByAddingTimeInterval:seconds];
    self.markDateB = todoDate;
    self.timeLineEndDate = [self.markDateB dateByAddingTimeInterval:diff];
    self.timeLineDatasource = [self fetchTimeLineDataSource];
    [self.collentionView reloadData];
}

- (BOOL)isDraging{
    return self.collentionView.isDragging;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.timeLineDatasource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MHLumiCameraTimeLineCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell configureCellWithDataUnit: self.timeLineDatasource[indexPath.item]];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //指示针在collectionView中的X坐标
    CGFloat indicatorViewXInCollectionView = self.collentionView.contentOffset.x + CGRectGetWidth(self.frame)/2.0;
    //指示针当前所在indexpath
    NSIndexPath *indexPath = [self.collentionView indexPathForItemAtPoint:CGPointMake(indicatorViewXInCollectionView, 10)];
    //cell的Frame
    if (indexPath == nil){
        return;
    }
    CGRect cellFrame = [self.collentionView layoutAttributesForItemAtIndexPath:indexPath].frame;
    //indexpath对应的dataUnit
    MHLumiCameraTimeLineDataUnit *dataUnit = self.timeLineDatasource[indexPath.item];
    //每一小格的宽度
//    CGFloat space = CGRectGetWidth(cellFrame)/dataUnit.countOfSeparated;
    //指针在cell中的x坐标偏移量
    CGFloat dx = indicatorViewXInCollectionView - cellFrame.origin.x;
    //指在第几小格
//    NSInteger statusNum = dx/space;
//    NSLog(@"dx = %f, index = %ld, statusNum = %ld", dx, (long)indexPath.item, (long)statusNum);
    self.currentDate = [self dateWithProcess:dx/CGRectGetWidth(cellFrame) betweenStartDate:dataUnit.startDate andEndDate:dataUnit.endDate];
    self.liveTimerLabel.hidden = NO;
    self.liveTimerLabel.text = [self.dateFormatter stringFromDate:self.currentDate];
    if ([self.delegate respondsToSelector:@selector(cameraTimeLineViewDidScroll:)]){
        [self.delegate cameraTimeLineViewDidScroll:self];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(cameraTimeLineViewWillBeginDragging:)]){
        [self.delegate cameraTimeLineViewWillBeginDragging:self];
    }
    NSLog(@"%s",__FUNCTION__);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(cameraTimeLineViewEndDragging:)]){
        [self.delegate cameraTimeLineViewEndDragging:self];
    }
    NSLog(@"%s",__FUNCTION__);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(cameraTimeLineViewEndDragging:)]){
        [self.delegate cameraTimeLineViewEndDragging:self];
    }
    NSLog(@"%s",__FUNCTION__);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate){
        if ([self.delegate respondsToSelector:@selector(cameraTimeLineViewEndDragging:)]){
            [self.delegate cameraTimeLineViewEndDragging:self];
        }
    }
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - UIOneLineCollectionViewLayoutDelegate
- (CGSize)oneLineLayout:(MHLumiUIOneLineCollectionViewLayout *)oneLineLayout itemSizeAtIndex:(NSUInteger)index{
    return CGSizeMake(kItemWidth, CGRectGetHeight(self.bounds));
}

#pragma mark - getter and setter
- (UICollectionView *)collentionView{
    if(!_collentionView){
        MHLumiUIOneLineCollectionViewLayout *layout = [[MHLumiUIOneLineCollectionViewLayout alloc] init];
        layout.delegate = self;
        UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [cv registerClass:[MHLumiCameraTimeLineCVCell class] forCellWithReuseIdentifier:@"cell"];
        cv.dataSource = self;
        cv.delegate = self;
        cv.showsHorizontalScrollIndicator = NO;
        cv.showsVerticalScrollIndicator = NO;
        cv.bounces = NO;
        cv.decelerationRate = UIScrollViewDecelerationRateFast;
        cv.backgroundColor = [UIColor clearColor];
        _collentionView = cv;
    }
    return _collentionView;
}

- (UIView *)indicatorView{
    if (!_indicatorView){
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = [UIColor redColor];
    }
    return _indicatorView;
}

- (UILabel *)liveTimerLabel{
    if (!_liveTimerLabel){
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.textColor = [UIColor redColor];
        aLabel.font = [UIFont systemFontOfSize:14];
        aLabel.layer.cornerRadius = 3;
        aLabel.layer.masksToBounds = YES;
        aLabel.hidden = YES;
        _liveTimerLabel = aLabel;
    }
    return _liveTimerLabel;
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter){
        NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
        aDateFormatter.dateFormat = @"MM-dd HH:mm";
        //yyyy-MM-dd
        aDateFormatter.timeZone = [NSTimeZone localTimeZone];
        _dateFormatter = aDateFormatter;
    }
    return _dateFormatter;
}

#pragma mark - private function
- (void)scrollToDate:(NSDate *)date andAnimated:(BOOL)animated{    
    if (date == nil){
        return;
    }
    NSDate *todoDate = date;
    if ([date earlierDate:self.timeLineStartDate] == date){
        todoDate = self.timeLineStartDate;
    }
    
    if ([date laterDate:self.timeLineEndDate] == date){
        todoDate = self.timeLineEndDate;
    }
    NSTimeInterval dix = self.timeLineEndDate.timeIntervalSince1970 - self.timeLineStartDate.timeIntervalSince1970;
    
    //指示针在collectionView中的X坐标
    CGFloat indicatorViewXInCollectionView = self.collentionView.contentOffset.x + CGRectGetWidth(self.frame)/2.0;
    //指示针当前所在indexpath
    NSIndexPath *indexPath = [self.collentionView indexPathForItemAtPoint:CGPointMake(indicatorViewXInCollectionView, 10)];
    //cell的Frame
    NSDate *pointDate = nil;
    if (indexPath == nil){
        pointDate = self.currentDate;
    }else{
        CGRect cellFrame = [self.collentionView layoutAttributesForItemAtIndexPath:indexPath].frame;
        //indexpath对应的dataUnit
        MHLumiCameraTimeLineDataUnit *dataUnit = self.timeLineDatasource[indexPath.item];
        //指针在cell中的x坐标偏移量
        CGFloat dx = indicatorViewXInCollectionView - cellFrame.origin.x;
        pointDate = [self dateWithProcess:dx/CGRectGetWidth(cellFrame) betweenStartDate:dataUnit.startDate andEndDate:dataUnit.endDate];
    }

    NSTimeInterval todoDix = todoDate.timeIntervalSince1970 - pointDate.timeIntervalSince1970;
    CGFloat todoX = todoDix*((self.collentionView.contentSize.width)/dix);
    if (ABS(todoX) <= 1){
        return;
    }
    todoX = MIN(self.collentionView.contentSize.width-self.collentionView.contentInset.right, self.collentionView.contentOffset.x+todoX);
    todoX = MAX(todoX, 0-self.collentionView.contentInset.left);
    [self.collentionView setContentOffset:CGPointMake(todoX, 0) animated:animated];
}

- (NSArray <MHLumiCameraTimeLineDataUnit *>*)fetchTimeLineDataSource{
    NSDateFormatter *aDateFormatter = [NSDateFormatter timeLineDateFormatter];
    NSDate *startDate = self.timeLineStartDate;
    NSDate *endDate = self.timeLineEndDate;
    NSDate *markDate1 = self.markDateA;
    NSDate *markDate2 = self.markDateB;
    NSMutableArray <MHLumiCameraTimeLineDataUnit *>* dataUnits = [NSMutableArray array];
    for (NSTimeInterval timerInterval = startDate.timeIntervalSince1970;
         timerInterval < endDate.timeIntervalSince1970;
         timerInterval += 60*60) {
        MHLumiCameraTimeLineDataUnit *dataUnit = [[MHLumiCameraTimeLineDataUnit alloc] init];
        dataUnit.startDate = [NSDate dateWithTimeIntervalSince1970:timerInterval];
        dataUnit.endDate = [dataUnit.startDate dateByAddingTimeInterval:60*60];
        NSDate *midDate = [dataUnit.startDate dateByAddingTimeInterval:30*60];
        NSString *dateString = [aDateFormatter stringFromDate:midDate];
        NSString *hour = [dateString substringWithRange:NSMakeRange(11, 5)];
        NSString *date = [dateString substringToIndex:10];
        dataUnit.timeRepresentString = hour;//[NSString stringWithFormat:@"%@:00",hour];
        dataUnit.needShowTimeNoteLabel = [[hour substringToIndex:2] integerValue] == 0;
        dataUnit.dateRepresentString = date;
        dataUnit.countOfSeparated = 6;
        NSInteger mark1Index = [self indexOfDateBetweenStartDate:dataUnit.startDate andEndDate:dataUnit.endDate todoDate:markDate1 andMaxIndex:dataUnit.countOfSeparated];
        NSInteger mark2Index = [self indexOfDateBetweenStartDate:dataUnit.startDate andEndDate:dataUnit.endDate todoDate:markDate2 andMaxIndex:dataUnit.countOfSeparated];
        
        if ([dataUnit.endDate earlierDate:markDate1] == dataUnit.endDate
            || [dataUnit.startDate laterDate:markDate2] == dataUnit.startDate){
            NSSet<NSNumber *>* set = [NSMutableSet set];
            for (NSInteger index = 0; index<dataUnit.countOfSeparated; index++) {
                set = [set setByAddingObject:[NSNumber numberWithInteger:index]];
            }
            dataUnit.enableRange = [NSSet set];
            dataUnit.disableRange = set;
        }else if ([dataUnit.startDate laterDate:markDate1] == dataUnit.startDate && [endDate earlierDate:markDate2] == dataUnit.endDate){
            NSSet<NSNumber *>* set = [NSMutableSet set];
            for (NSInteger index = 0; index<dataUnit.countOfSeparated; index++) {
                set = [set setByAddingObject:[NSNumber numberWithInteger:index]];
            }
            dataUnit.enableRange = set;
            dataUnit.disableRange = [NSSet set];
        }else if (mark1Index >= 0 && mark2Index >= 0){
            NSSet<NSNumber *>* enableSet = [NSMutableSet set];
            for (NSInteger index = mark1Index; index<=mark2Index; index++) {
                enableSet = [enableSet setByAddingObject:[NSNumber numberWithInteger:index]];
            }
            dataUnit.enableRange = enableSet;
            NSSet<NSNumber *>* disableSet = [NSMutableSet set];
            for (NSInteger index = 0; index<dataUnit.countOfSeparated; index++) {
                if (![enableSet containsObject:[NSNumber numberWithInteger:index]]){
                    disableSet = [disableSet setByAddingObject:[NSNumber numberWithInteger:index]];
                }
            }
            dataUnit.disableRange = disableSet;
        }else if (mark2Index >= 0 && mark1Index < 0){
            NSSet<NSNumber *>* enableSet = [NSMutableSet set];
            for (NSInteger index = 0; index<=mark2Index; index++) {
                enableSet = [enableSet setByAddingObject:[NSNumber numberWithInteger:index]];
            }
            dataUnit.enableRange = enableSet;
            NSSet<NSNumber *>* disableSet = [NSMutableSet set];
            for (NSInteger index = mark2Index + 1; index<dataUnit.countOfSeparated; index++) {
                if (![enableSet containsObject:[NSNumber numberWithInteger:index]]){
                    disableSet = [disableSet setByAddingObject:[NSNumber numberWithInteger:index]];
                }
            }
            dataUnit.disableRange = disableSet;
        }else if (mark1Index >= 0 && mark2Index < 0){
            NSSet<NSNumber *>* enableSet = [NSMutableSet set];
            for (NSInteger index = mark1Index; index<dataUnit.countOfSeparated; index++) {
                enableSet = [enableSet setByAddingObject:[NSNumber numberWithInteger:index]];
            }
            dataUnit.enableRange = enableSet;
            NSSet<NSNumber *>* disableSet = [NSMutableSet set];
            for (NSInteger index = 0; index<mark1Index; index++) {
                if (![enableSet containsObject:[NSNumber numberWithInteger:index]]){
                    disableSet = [disableSet setByAddingObject:[NSNumber numberWithInteger:index]];
                }
            }
            dataUnit.disableRange = disableSet;
        }
        
        [dataUnits addObject:dataUnit];
    }
    return dataUnits;
}

- (NSInteger)indexOfDateBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate todoDate:(NSDate *)todoDate andMaxIndex:(NSInteger)maxIndex{
    if ([endDate earlierDate:todoDate] == endDate || [startDate laterDate:todoDate] == startDate){
        return -1;
    }
    NSTimeInterval dix = todoDate.timeIntervalSince1970 - startDate.timeIntervalSince1970;
    NSInteger index = (int)(dix*maxIndex / (endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970));
    return index;
}

- (NSDate *)dateWithProcess:(CGFloat)process betweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate{
    if (process <= 0){
        return startDate;
    }
    if (process >= 1){
        return endDate;
    }
    return [startDate dateByAddingTimeInterval:process * (endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)];
}
@end
