//
//  MHGatewayIFTTTLogCategoryCell.m
//  MiHome
//
//  Created by ayanami on 16/6/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneLogCategoryCell.h"
#import <MiHomeKit/MHTimeUtils.h>
#import "NSString+WeiboStringDrawing.h"
#import "MHExpandableCategory.h"
#import "MHDataGatewaySceneLog.h"

@implementation MHGatewaySceneLogCategoryCell

{
    UIImageView* _historyImage;
    UILabel* _historyName;
    UILabel* _historyResult;
    
    UIImageView*    _markerUp;
    UIImageView*    _markerDown;
    UIView*         _vSpLine;
    UIImageView*    _expandArrow;
    
    //For fake log
    UILabel*        _labelDay;
    UILabel*        _labelMonth;
    UILabel*        _labelWeekday;
    
    MHExpandableCategory* _category;
}

- (void)configureWithDataObject:(MHExpandableCategory *)category {
    self.drawSeparateLine = YES;
    self.separateLineLeftGap = 70;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _category = category;
    MHDataGatewaySceneLog* history = (MHDataGatewaySceneLog*)category.data;
    if ([history.recordType isEqualToString:@"fake"]) {
        _historyImage.hidden = _historyName.hidden = _historyResult.hidden = _vSpLine.hidden = _markerUp.hidden = _markerDown.hidden = _expandArrow.hidden = YES;
        _labelDay.hidden = _labelMonth.hidden = _labelWeekday.hidden = NO;
        [self buildSubviewsForFakeLog];
    } else {
        _historyImage.hidden = _historyName.hidden = _historyResult.hidden = _vSpLine.hidden = NO;
        _labelDay.hidden = _labelMonth.hidden = _labelWeekday.hidden = YES;
        [self buildSubviews];
    }
}

- (void)buildSubviews {
    XM_WS(ws);
    
    MHDataGatewaySceneLog* history = (MHDataGatewaySceneLog*)_category.data;
    
    if (!_vSpLine) {
        _vSpLine = [[UIView alloc] init];
        _vSpLine.backgroundColor = [MHColorUtils colorWithRGB:0xdcdcdc];
        [self.contentView addSubview:_vSpLine];
        [_vSpLine mas_makeConstraints:^(MASConstraintMaker *make) {
            XM_SS(ss, ws);
            make.leading.equalTo(ws.contentView).offset(37.0);
            make.top.equalTo(ws.contentView);
            make.bottom.equalTo(ws.contentView);
            make.width.mas_equalTo(0.5);
        }];
    }
    
    if (_historyImage == nil) {
        _historyImage = [UIImageView new];
        [self.contentView addSubview:_historyImage];
        [_historyImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(ws.contentView).offset(25.0);
            make.centerY.equalTo(ws.contentView);
            make.width.height.mas_equalTo(25.0);
        }];
    }
    _historyImage.image = [history historyIcon];
    
//    if (!_markerUp) {
//        _markerUp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ift_history_marker"]];
//        [self.contentView addSubview:_markerUp];
//        [_markerUp mas_makeConstraints:^(MASConstraintMaker *make) {
//            XM_SS(ss, ws);
//            make.centerX.equalTo(ss->_vSpLine);
//            make.top.equalTo(ws.contentView);
//            make.size.mas_equalTo(CGSizeMake(7, 7));
//        }];
//    }
//    _markerUp.hidden = history.hasPrev;
//    _markerUp.hidden = YES;
    
//    if (!_markerDown) {
//        _markerDown = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ift_history_marker"]];
//        [self.contentView addSubview:_markerDown];
//        [_markerDown mas_makeConstraints:^(MASConstraintMaker *make) {
//            XM_SS(ss, ws);
//            make.centerX.equalTo(ss->_vSpLine);
//            make.bottom.equalTo(ws.contentView);
//            make.size.mas_equalTo(CGSizeMake(7, 7));
//        }];
//    }
//    _markerDown.hidden = history.hasNext || [_category expanded];
    
    if (_historyName == nil) {
        _historyName = [UILabel new];
        _historyName.font = [UIFont systemFontOfSize:15.0];
        _historyName.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self.contentView addSubview:_historyName];
        [_historyName mas_makeConstraints:^(MASConstraintMaker *make) {
            XM_SS(ss, ws);
            make.leading.equalTo(ss->_historyImage.mas_trailing).offset(20.0);
//            make.trailing.equalTo(ws.contentView).offset(-20.0);
            make.bottom.equalTo(ws.contentView.mas_centerY).with.offset(-2);
            make.right.equalTo(ws.contentView.mas_right).with.offset(-40);
        }];
    }
    _historyName.text = history.recordName;
    
    if (_historyResult == nil) {
        _historyResult = [UILabel new];
        _historyResult.font = [UIFont systemFontOfSize:12.0];
        _historyResult.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.contentView addSubview:_historyResult];
        [_historyResult mas_makeConstraints:^(MASConstraintMaker *make) {
            XM_SS(ss, ws);
            make.leading.equalTo(ss->_historyName);
            make.trailing.equalTo(ss->_historyName);
            make.top.equalTo(ws.contentView.mas_centerY).with.offset(4);
        }];
    }
    NSDate* executeDate = [NSDate dateWithTimeIntervalSince1970:history.executeTime];
    NSString* result = [NSString stringWithFormat:@"%@ %@",
                        [MHTimeUtils localFormattedStringForDate:executeDate dateFormat:@"HH:mm"],
                        ([history isSucceedExecuted] ? NSLocalizedStringFromTable(@"ifttt.scene.execute.result.succeed", @"plugin_gateway","执行成功") : NSLocalizedStringFromTable(@"ifttt.scene.execute.result.failed", @"plugin_gateway", "执行失败"))];
    _historyResult.text = result;
    _historyResult.textColor = [history isSucceedExecuted] ? [[UIColor blackColor] colorWithAlphaComponent:0.5] : [[UIColor redColor] colorWithAlphaComponent:0.5];
    
    if (!_expandArrow) {
//        _expandArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"std_home_btn_expanding"]];
                _expandArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_scene_log_rightarrow"]];
        [self.contentView addSubview:_expandArrow];
        [_expandArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(ws.contentView);
            make.trailing.equalTo(ws.contentView).offset(-20.0);
            make.size.mas_equalTo(CGSizeMake(7, 14));
        }];
    }
//    _expandArrow.hidden = !_category.expandable;
//    if (!_expandArrow.hidden) {
//        CGFloat angle = M_PI;
//        if (_category.expanded) {
//            angle = 0;
//        }
//        _expandArrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
//    }
}

#pragma mark - fake
- (void)buildSubviewsForFakeLog {
    
    MHDataGatewaySceneLog* history = (MHDataGatewaySceneLog*)_category.data;
    
    if (!_labelDay) {
        _labelDay = [[UILabel alloc] init];
        _labelDay.font = [UIFont systemFontOfSize:24];
        _labelDay.textColor = [MHColorUtils colorWithRGB:0x333333];
        _labelDay.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_labelDay];
    }
    
    
    if (!_labelMonth) {
        _labelMonth = [[UILabel alloc] init];
        _labelMonth.font = [UIFont systemFontOfSize:11];
        _labelMonth.textColor = [MHColorUtils colorWithRGB:0x999999];
        _labelMonth.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_labelMonth];
    }
    
    if (!_labelWeekday) {
        _labelWeekday = [[UILabel alloc] init];
        _labelWeekday.font = [UIFont systemFontOfSize:11];
        _labelWeekday.textColor = [MHColorUtils colorWithRGB:0x999999];
        _labelWeekday.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_labelWeekday];
    }
    
    NSDate* logDate = [NSDate dateWithTimeIntervalSince1970:history.executeTime];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d"];
    _labelDay.text = [dateFormat stringFromDate:logDate];
    
    CGSize sizeDay = [_labelDay.text singleLineSizeWithFont:_labelDay.font];
    _labelDay.frame = CGRectMake(20, (CGRectGetHeight(self.contentView.frame) - sizeDay.height)/ 2.0f, sizeDay.width, sizeDay.height);
    
    [dateFormat setDateFormat:@"MMMM"];
    _labelMonth.text = [dateFormat stringFromDate:logDate];
    CGSize sizeMonth = [_labelMonth.text singleLineSizeWithFont:_labelMonth.font];
    CGFloat monthX = CGRectGetMaxX(_labelDay.frame) + 3;
    CGFloat monthY = CGRectGetMaxY(_labelDay.frame) - sizeMonth.height - 3;
    _labelMonth.frame = CGRectMake(monthX, monthY, sizeMonth.width, sizeMonth.height);
    
    [dateFormat setDateFormat:@"eeee"];
    _labelWeekday.text = [dateFormat stringFromDate:logDate];
    
    CGSize sizeWeekday = [_labelWeekday.text singleLineSizeWithFont:_labelWeekday.font];
    CGFloat weekdayX = CGRectGetWidth(self.contentView.frame) - sizeWeekday.width - 20;
    CGFloat weekdayY = CGRectGetMaxY(_labelMonth.frame) - sizeWeekday.height;
    _labelWeekday.frame = CGRectMake(weekdayX, weekdayY, sizeWeekday.width, sizeWeekday.height);
}

@end
