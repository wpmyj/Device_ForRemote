//
//  MHGatewayIFTTTLogContentCell.m
//  MiHome
//
//  Created by ayanami on 16/6/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneLogContentCell.h"
#import "MHExpandableContent.h"
#import "MHDataIFTTTHistory.h"
#import "MHDataIFTTTHistoryMessage.h"
#import "MHDataGatewaySceneLog.h"
#import "MHDataGatewaySceneLogMessage.h"

@implementation MHGatewaySceneLogContentCell
{
    UILabel* _historyName;
    UILabel* _historyDetail;
    UILabel* _historyResult;
    UIView*  _vSpLine;
    UIImageView* _markerDown;
}

- (void)configureWithDataObject:(MHExpandableContent *)content
{
    MHDataIFTTTHistoryMessage* message = (MHDataIFTTTHistoryMessage*)content.data;
    
    self.drawSeparateLine = YES;
    self.separateLineLeftGap = 70;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    XM_WS(ws);
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
    
    if (_historyName == nil) {
        _historyName = [UILabel new];
        _historyName.font = [UIFont systemFontOfSize:15.0];
        _historyName.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self.contentView addSubview:_historyName];
        [_historyName mas_makeConstraints:^(MASConstraintMaker *make) {
            XM_SS(ss, ws);
            make.leading.equalTo(ws.contentView).offset(70.0);
//            make.trailing.equalTo(ws.contentView).offset(-20.0);
            make.bottom.equalTo(ws.contentView.mas_centerY).with.offset(-2);
            make.right.equalTo(ws.contentView.mas_right).with.offset(-60);
        }];
    }
    _historyName.text = message.targetDesc;
    
    if (!_historyDetail) {
        _historyDetail = [UILabel new];
        _historyDetail.font = [UIFont systemFontOfSize:12.0];
        _historyDetail.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.contentView addSubview:_historyDetail];
        [_historyDetail mas_makeConstraints:^(MASConstraintMaker *make) {
            XM_SS(ss, ws);
            make.leading.equalTo(ss->_historyName);
//            make.trailing.equalTo(ss->_historyName);
            make.top.equalTo(ws.contentView.mas_centerY).with.offset(4);
            make.right.equalTo(ws.contentView.mas_right).with.offset(-60);
        }];
    }
    _historyDetail.text = message.methodDesc;
    
    if (_historyResult == nil) {
        _historyResult = [UILabel new];
        _historyResult.font = [UIFont systemFontOfSize:12.0];
        _historyResult.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _historyResult.textAlignment = NSTextAlignmentRight;
        _historyResult.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        [self.contentView addSubview:_historyResult];
        [_historyResult mas_makeConstraints:^(MASConstraintMaker *make) {
            XM_SS(ss, ws);
            make.centerY.equalTo(ws.contentView);
            make.trailing.equalTo(ws.contentView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(70,20));
        }];
    }
    _historyResult.text = [message errorDetail];
    
    if (!_markerDown) {
        _markerDown = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ift_history_marker"]];
        [self.contentView addSubview:_markerDown];
        [_markerDown mas_makeConstraints:^(MASConstraintMaker *make) {
            XM_SS(ss, ws);
            make.centerX.equalTo(ss->_vSpLine);
            make.bottom.equalTo(ws.contentView);
            make.size.mas_equalTo(CGSizeMake(7, 7));
        }];
    }
    _markerDown.hidden = !message.isLast || [(MHDataIFTTTHistory*)message.history hasNext];
}


@end
